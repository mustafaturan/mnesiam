defmodule Mnesiam.Application do
  @moduledoc false

  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Mnesiam.init_mnesia()

    children = [
    ]

    opts = [strategy: :one_for_one, name: Mnesiam.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
