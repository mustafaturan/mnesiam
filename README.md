# Mnesiam

Mnesiam makes clustering easy for Mnesia database.

The module docs can be found at [https://hexdocs.pm/mnesiam](https://hexdocs.pm/mnesiam).

## Installation

The package can be installed by adding `mnesiam` to your list of dependencies in `mix.exs`:

```elixir
defp deps do
  [{:mnesiam, "~> MAJ.MIN"}]
end
```

Ensure `mnesiam` is started before your application.

Elixir Version >= 1.6 with `libcluster`

```elixir
    ...

    cluster_data = Application.get_env(:libcluster, :topologies)

    children = [
      {
        Cluster.Supervisor,
        [
          cluster_data,
          [name: MyApp.ClusterSupervisor]
        ]
      },
      {
        Mnesiam.Supervisor,
        [
          cluster_data[:myapp][:config][:hosts],
          [name: MyApp.MnesiamSupervisor]
        ]
      },

    ...
```

Elixir Version >= 1.6 without `libcluster`

```elixir
    ...

    children = [
      {
        Mnesiam.Supervisor,
        [
          [:"a@127.0.0.1", :"b@127.0.0.1"],
          [name: MyApp.MnesiamSupervisor]
        ]
      },

    ...
```

Edit your app's `config.exs` to add list of mnesia stores:

```elixir
config :mnesiam,
  stores: [MyApp.SampleStore, ...],
  schema_type: :disc_copies, # defaults to :ram_copies
  table_load_timeout: 600_000 # milliseconds
```

## Usage

### Table creation

Create a table store and add it to your app's config.exs. Note: All stores *MUST* implement its own `init_store/0` to crete table and `copy_store/0` to copy table:

```elixir
defmodule MyApp.SampleStore do
  @moduledoc """
  Sample store implementation
  """

  @table :sample_store

  @doc """
  Mnesiam will call this method to init table
  """
  def init_store do
    :mnesia.create_table(@table,
      [ram_copies: [Node.self()], attributes: [:id, :topic_id, :event]])
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
```

### Clustering

If you are using `libcluster` or another clustering library just ensure that clustering library starts earlier than `mnesiam`. That's all, you do not need to do rest.

If you are not using `libcluster` or similar clustering library then:

- When a node joins to an erlang/elixir cluster, run `Mnesiam.init_store/1` function on the *new node*; this will init and copy table contents from other online nodes.

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

Copyright (c) 2018 Mustafa Turan

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
