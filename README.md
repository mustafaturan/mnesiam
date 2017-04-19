# Mnesiam

Mnesiam makes clustering easy for Mnesia database.

The module docs can be found at [https://hexdocs.pm/mnesiam](https://hexdocs.pm/mnesiam).

## Installation

The package can be installed by adding `mnesiam` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:mnesiam, "~> 0.1.0"}]
end
```

Ensure `mnesiam` is started before your application.

Elixir Version >= 1.4 with `libcluster`

```elixir
def application do
  [extra_applications: [:libcluster, :mnesiam]]
end
```

Elixir Version >= 1.4 without `libcluster`

```elixir
def application do
  [extra_applications: [:mnesiam]]
end
```

Edit your app's `config.exs` to add list of mnesia stores:

```elixir
config :mnesiam,
  stores: [Mnesiam.Support.SampleStore, ...],
  table_load_timeout: 600_000 # milliseconds
```

## Usage

### Table creation

Create a table store and add it to your app's config.exs. Note: All stores *MUST* implement its own `init_store/0` to crete table and `copy_store/0` to copy table:

```elixir
defmodule Mnesiam.Support.SampleStore do
  @moduledoc """
  Sample store implementation
  """

  alias :mnesia, as: Mnesia

  @table :sample_store

  @doc """
  Mnesiam will call this method to init table
  """
  def init_store do
    Mnesia.create_table(@table,
      [ram_copies: [Node.self()], attributes: [:id, :topic_id, :event]])
    # Sample index
    Mnesia.add_table_index(@table, :topic_id)
    # Add table subscriptions to here
    # ...
  end

  @doc """
  Mnesiam will call this method to copy table
  """
  def copy_store do
    Mnesia.add_table_copy(@table, Node.self(), :ram_copies)
  end
end

```

### Clustering

If you are using `libcluster` or another clustering library just ensure that clustering library starts earlier than `mneasiam`. That's all, you do not need to do rest.

If you are not using `libcluster` or similar clustering library then:

- When a node joins to an erlang/elixir cluster, run `Mnesiam.init_store()` function on the *new node*; this will init and copy table contents from other online nodes.

Enjoy!

## Warnings

Use at your own risk, no warranty!

## Contributing

For any issues, bugs, documentation, enhancements:

1) Fork the project

2) Make your improvements and write your tests.

3) Make a pull request.

## License

Apache License 2.0
