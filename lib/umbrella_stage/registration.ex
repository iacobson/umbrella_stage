defmodule UmbrellaStage.Registration do
  @moduledoc false
  require Logger
  alias :mnesia, as: Mnesia

  def init() do
    Mnesia.create_schema([node()])
    Mnesia.start()
  end

  def clear() do
    Mnesia.delete_table(UmbrellaStage.Producers)
    Mnesia.delete_table(UmbrellaStage.Consumers)
  end

  def register(:producers, {:error, :not_named}) do
    Logger.error("Producer or ProducerConsumer with pid: #{inspect(self())} is not named and will not register")
  end

  def register(:producers, name) do
    Mnesia.create_table(UmbrellaStage.Producers, [attributes: [:name, :pid]])
    Mnesia.transaction fn ->
      Mnesia.write({UmbrellaStage.Producers, name, self()})
    end
  end

  def register(:consumers, {producer_name, opts}) do
    Mnesia.create_table(UmbrellaStage.Consumers, [attributes: [:producer_name, :pid, :opts]])
    Mnesia.transaction fn ->
      Mnesia.write({UmbrellaStage.Consumers, producer_name, self(), opts})
    end
  end

  def find(:producers), do: find(:producers, :_)
  def find(:producers, name) do
    case lookup({UmbrellaStage.Producers, name, :_}) do
      {:atomic, producers} ->
        producers
        |> Enum.map(&(Tuple.delete_at(&1, 0)))
      _ ->
        []
    end
  end

  def find(:consumers), do: find(:consumers, :_, :_)
  def find(:consumers, producer_name: producer_name), do: find(:consumers, producer_name, :_)
  def find(:consumers, pid: pid),                     do: find(:consumers, :_, pid)
  def find(:consumers, producer_name, pid) do
    case lookup({UmbrellaStage.Consumers, producer_name, pid, :_}) do
      {:atomic, consumers} ->
        consumers
        |> Enum.map(&(Tuple.delete_at(&1, 0)))
      _ ->
        []
    end
  end

  defp lookup(match) do
    Mnesia.transaction fn ->
      Mnesia.match_object(match)
    end
  end
end
