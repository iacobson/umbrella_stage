defmodule UmbrellaStage.Checker do
  @moduledoc false
  require Logger
  alias UmbrellaStage.Registration

  def check_consumer_subscriptions(consumer_pid) do
    Registration.find(:consumers, pid: consumer_pid)
    |> Enum.map(&find_producer/1)
    |> Enum.reject(&(&1 == nil))
  end

  def check_producer_subscribers(_, {:error, :not_named}) do
    Logger.error("Producer or ProducerConsumer with pid: #{inspect(self())} is not named and will not receive subscriptions")
    []
  end

  def check_producer_subscribers(producer_pid, producer_name) do
    Registration.find(:consumers, producer_name: producer_name)
    |> Enum.map(&map_subscriptions(producer_pid, &1))
  end

  def find_producer({producer_name, consumer_pid, opts}) do
    case Registration.find(:producers, producer_name) do
      [{_producer_name, producer_pid}] ->
        {consumer_pid, producer_pid, opts}
      [] ->
        nil
      match ->
        Logger.error("Error finding producer: #{inspect(match)} | Producer name: #{inspect(producer_name)}")
        nil
    end
  end

  defp map_subscriptions(producer_pid, {_producer_name, consumer_pid, opts}) do
    {consumer_pid, producer_pid, opts}
  end
end
