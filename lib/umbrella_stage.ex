defmodule UmbrellaStage do
  @moduledoc ~S"""
  Subscribes GenStage consumers to producers across Elixir Umbrella apps.
  """

  require Logger
  alias UmbrellaStage.{Registration, Checker, Subscriber}


  defmacro __using__(args) do
    quote do

      def umbrella_sync_subscribe do
        UmbrellaStage.sync_subscribe(unquote(args))
      end
    end
  end


  @doc false
  def sync_subscribe(type: :consumer, producers: producers) do
    Enum.each(producers, &Registration.register(:consumers, normalize_producer(&1)))

    self()
    |> Checker.check_consumer_subscriptions()
    |> Enum.each(&Subscriber.subscribe/1)
  end

  @doc false
  def sync_subscribe(type: :producer) do
    producer_name = process_name()
    Registration.register(:producers, producer_name)

    self()
    |> Checker.check_producer_subscribers(producer_name)
    |> Enum.each(&Subscriber.subscribe/1)
  end

  @doc false
  def sync_subscribe(type: :producer_consumer, producers: producers) do
    sync_subscribe(type: :producer)
    sync_subscribe(type: :consumer, producers: producers)
  end

  @doc false
  def sync_subscribe(args) do
    Logger.error("""
    Incorrect args in UmbrellaStage.
    #{inspect(args)}
    This GenStage will not subscribe or receive subscriptions.
    """)
  end


  defp process_name do
    case Process.info(self(), :registered_name) do
      {:registered_name, name} when is_atom(name) ->
        name
      _ ->
        {:error, :not_named}
    end
  end

  defp normalize_producer({producer_name}),       do: {producer_name, []}
  defp normalize_producer({producer_name, opts}), do: {producer_name, opts}
  defp normalize_producer(producer_name),         do: {producer_name, []}
end
