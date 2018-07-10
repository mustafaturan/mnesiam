defmodule Mnesiam.Support.SampleStore do
  @moduledoc """
  Sample store implementation
  """
  @table :sample_store

  @doc """
  Mnesiam will call this method to init table
  """
  def init_store do
    :mnesia.create_table(@table, ram_copies: [Node.self()], attributes: [:id, :topic_id, :event])
    # Sample index
    :mnesia.add_table_index(@table, :topic_id)
    # Add table subscriptions to here
    # ...
  end

  @doc """
  Mnesiam will call this method to copy table
  """
  def copy_store do
    :mnesia.add_table_copy(@table, Node.self(), :ram_copies)
  end
end
