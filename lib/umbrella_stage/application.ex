defmodule UmbrellaStage.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      supervisor(Registry, [:duplicate, Registry.Subscriptions]),
    ]

    opts = [strategy: :one_for_one, name: UmbrellaStage.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
