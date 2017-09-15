defmodule UmbrellaStage do
  @moduledoc """
  This module subscribes GenStage consumers to producers.
  ## Usage
  `use` the `UmbrellaStage` in the GenStages servers. It required 2 arguments:  
  - `:type` - is the GenStage type: `:producer`, `:producer_consumer` or `:consumer`
  - `:producers` - required only for consumers and producer_consumers.
      It's the list of producers, the consumer will subscribe to, in the following format:
      `{ProducerName, [subscription_options]}`
  Then call `sync_subscribe()` in the GenStage `init`

  ### Example Consumer
  ```
  use UmbrellaStage,
    type: :consumer,
    producers: [
      {GenericThing.ProducerConsumer, [max_demand: 10]}
    ]

  def init() do
    sync_subscribe()
    .....
  end
  ```

  ### Example Producer
  ```
  use UmbrellaStage,
    type: :producer

  def init() do
    sync_subscribe()
    .....
  end
  ```
  """

  require Logger
  alias UmbrellaStage.{Registration, Checker, Subscriber}

  defmacro __using__(args) do
    quote do
      import unquote(__MODULE__)

      def sync_subscribe do
        sync_subscribe(unquote(args))
      end
    end
  end


  def sync_subscribe(type: :consumer, producers: producers) do
    Enum.each(producers, &Registration.register(:consumers, &1))

    self()
    |> Checker.check_consumer_subscriptions()
    |> Enum.each(&Subscriber.subscribe/1)
  end

  def sync_subscribe(type: :producer) do
    producer_name = process_name()
    Registration.register(:producers, producer_name)

    self()
    |> Checker.check_producer_subscribers(producer_name)
    |> Enum.each(&Subscriber.subscribe/1)
  end

  def sync_subscribe(type: :producer_consumer, producers: producers) do
    sync_subscribe(type: :producer)
    sync_subscribe(type: :consumer, producers: producers)
  end

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
end
