defmodule Mnesiam.Store do
  @moduledoc """
  Mnesia Store Manager
  """

  alias :mnesia, as: Mnesia

  @doc """
  Init tables
  """
  def init_tables do
    case Mnesia.system_info(:extra_db_nodes) do
      [] -> create_tables()
      [_|_] -> copy_tables()
    end
  end

  @doc """
  Ensure tables loaded
  """
  def ensure_tables_loaded do
    tables = Mnesia.system_info(:local_tables)
    case Mnesia.wait_for_tables(tables, table_load_timeout()) do
      :ok -> :ok
      {:error, reason} -> {:error, reason}
      {:timeout, bad_tables} -> {:error, {:timeout, bad_tables}}
    end
  end

  @doc """
  Create tables
  """
  def create_tables do
    Enum.each(stores(), fn (data_mapper) ->
      apply(data_mapper, :init_store, [])
    end)
    :ok
  end

  @doc """
  Copy tables
  """
  def copy_tables do
    Enum.each(stores(), fn (data_mapper) ->
      apply(data_mapper, :copy_store, [])
    end)
    :ok
  end

  @doc """
  Copy schema
  """
  def copy_schema(cluster_node) do
    copy_type = Application.get_env(:mnesiam, :schema_type, :ram_copies)
    case Mnesia.change_table_copy_type(:schema, cluster_node, copy_type) do
      {:atomic, :ok} -> :ok
      {:aborted, {:already_exists, :schema, _, _}} -> :ok
      {:aborted, reason} -> {:error, reason}
    end
  end

  @doc """
  Delete schema
  """
  def delete_schema do
    Mnesia.delete_schema([Node.self()])
  end

  @doc """
  Delete schema copy
  """
  def del_schema_copy(cluster_node) do
    case Mnesia.del_table_copy(:schema, cluster_node) do
      {:atomic, :ok} -> :ok
      {:aborted, reason} -> {:error, reason}
    end
  end

  defp stores do
    Application.get_env(:mnesiam, :stores)
  end

  defp table_load_timeout do
    Application.get_env(:mnesiam, :table_load_timeout, 600_000)
  end
end
