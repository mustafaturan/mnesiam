defmodule Mnesiam do
  @moduledoc """
  Mnesia Manager
  """

  require Logger
  alias Mnesiam.Store
  alias :mnesia, as: Mnesia

  @doc """
  Start Mnesia with/without a cluster
  """
  def init_mnesia do
    case Node.list() do
      [h|_t] -> join_cluster(h)
      [] -> start()
    end
  end

  @doc """
  Start Mnesia alone
  """
  def start do
    with :ok <- ensure_dir_exists(),
         :ok <- Store.init_schema(),
         :ok <- start_server(),
         :ok <- Store.init_tables(),
         :ok <- Store.ensure_tables_loaded() do
      :ok
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Join to a Mnesia cluster
  """
  def join_cluster(cluster_node) do
    with :ok <- ensure_stopped(),
         :ok <- Store.delete_schema(),
         :ok <- ensure_started(),
         :ok <- connect(cluster_node),
         :ok <- Store.copy_schema(Node.self()),
         :ok <- Store.copy_tables(),
         :ok <- Store.ensure_tables_loaded() do
      :ok
    else
      {:error, reason} ->
        Logger.log(:debug, fn -> inspect(reason) end)
        {:error, reason}
    end
  end

  @doc """
  Cluster status
  """
  def cluster_status do
    running = Mnesia.system_info(:running_db_nodes)
    stopped = Mnesia.system_info(:db_nodes) -- running
    if stopped == [] do
      [{:running_nodes, running}]
    else
      [{:running_nodes, running}, {:stopped_nodes, stopped}]
    end
  end

  @doc """
  Cluster with a node
  """
  def connect(cluster_node) do
    case Mnesia.change_config(:extra_db_nodes, [cluster_node]) do
      {:ok, [_cluster_node]} -> :ok
      {:ok, []}     -> {:error, {:failed_to_connect_node, cluster_node}}
      reason        -> {:error, reason}
    end
  end

  @doc """
  Running Mnesia nodes
  """
  def running_nodes do
    Mnesia.system_info(:running_db_nodes)
  end

  @doc """
  Is node in Mnesia cluster?
  """
  def node_in_cluster?(cluster_node) do
    Enum.member?(Mnesia.system_info(:db_nodes), cluster_node)
  end

  @doc """
  Is running Mnesia node?
  """
  def running_db_node?(cluster_node) do
    Enum.member?(running_nodes(), cluster_node)
  end

  defp ensure_started do
    with :ok <- start_server(),
         :ok <- wait_for(:start) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp ensure_stopped do
    with :stopped <- stop_server(),
         :ok <- wait_for(:stop) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp ensure_dir_exists do
    mnesia_dir = Mnesia.system_info(:directory)
    with false <- File.exists?(mnesia_dir),
         :ok <- File.mkdir(mnesia_dir) do
      :ok
    else
      true -> :ok
      {:error, reason} ->
        Logger.log(:debug, fn -> inspect(reason) end)
        {:error, reason}
    end
  end

  defp start_server do
    Mnesia.start()
  end

  defp stop_server do
    Mnesia.stop()
  end

  defp wait_for(:start) do
    case Mnesia.system_info(:is_running) do
      :yes      -> :ok
      :no       -> {:error, :mnesia_unexpectedly_stopped}
      :stopping -> {:error, :mnesia_unexpectedly_stopping}
      :starting ->
        Process.sleep(1_000)
        wait_for(:start)
    end
  end
  defp wait_for(:stop) do
    case Mnesia.system_info(:is_running) do
      :no       -> :ok
      :yes      -> {:error, :mnesia_unexpectedly_running}
      :starting -> {:error, :mnesia_unexpectedly_starting}
      :stopping ->
        Process.sleep(1_000)
        wait_for(:stop)
    end
  end
end
