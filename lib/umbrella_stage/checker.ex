defmodule UmbrellaStage.Checker do
  require Logger

  def check_consumer_subscriptions(consumer_pid) do
    Registry.Subscriptions
    |> Registry.lookup(:consumers)
    |> Enum.filter(&(match?({^consumer_pid, _}, &1)))
    |> Enum.map(&find_producer/1)
    |> Enum.reject(&(&1 == nil))
  end

  def check_producer_subscribers(_, {:error, :not_named}) do
    Logger.error("Producer or ProducerConsumer with pid: #{inspect(self())} is not named and will not receive subscriptions")
    []
  end

  def check_producer_subscribers(producer_pid, producer_name) do
    Registry.Subscriptions
    |> Registry.match(:consumers, {producer_name, :_})
    |> Enum.map(&map_subscriptions(producer_pid, &1))
  end


  defp find_producer({consumer_pid, {producer_name, opts}}) do
    case Registry.match(Registry.Subscriptions, :producers, producer_name) do
      [{producer_pid, ^producer_name}] ->
        {consumer_pid, producer_pid, opts}
      [] ->
        nil
      match ->
        Logger.error("Error finding producer: #{inspect(match)} | Producer name: #{inspect(producer_name)}")
        nil
    end
  end


  defp map_subscriptions(producer_pid, {consumer_pid, {_producer_name, opts}}) do
    {consumer_pid, producer_pid, opts}
  end
end
