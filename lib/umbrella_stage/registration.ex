defmodule UmbrellaStage.Registration do
  require Logger

  def register(:producers, {:error, :not_named}) do
    Logger.error("Producer or ProducerConsumer with pid: #{inspect(self())} is not named and will not register")
  end

  def register(type, producer) do
    {:ok, _} = Registry.register(
      Registry.Subscriptions,
      type,
      producer
    )
  end
end
