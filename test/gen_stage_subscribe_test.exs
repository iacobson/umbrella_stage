defmodule Integration.GenStageSubscribeTest do
  use ExUnit.Case
  alias Integration.GenStageSubscribeTest.Producer
  alias Integration.GenStageSubscribeTest.Consumer

  test "with the correct configuration the consumer si subscribed to the producer" do
    {:ok, _prod_pid} = Producer.start_link()
    {:ok, _cons_pid} = Consumer.start_link(self())

    Producer.dispatch_message("test_message")

    assert_receive {:received, ["test_message"]}
  end
end

defmodule Integration.GenStageSubscribeTest.Producer do
  use GenStage
  use UmbrellaStage,
    type: :producer

  # API

  def start_link do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def dispatch_message(message) do
    GenStage.call(__MODULE__, {:dispatch_message, message})
  end

  # SERVER

  def init(:ok) do
    sync_subscribe()
    {:producer, :no_state}
  end

  def handle_call({:dispatch_message, event}, _from, state) do
    {:reply, :ok, [event], state}
  end

  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end
end

defmodule Integration.GenStageSubscribeTest.Consumer do
  use GenStage
  use UmbrellaStage,
    type: :consumer,
    producers: [
      {Integration.GenStageSubscribeTest.Producer, [max_demand: 3]}
    ]

  # API

  def start_link(owner_pid) do
    GenStage.start_link(__MODULE__, owner_pid)
  end

  # SERVER

  def init(owner_pid) do
    sync_subscribe()
    {:consumer, owner_pid}
  end

  def handle_events(events, _from, owner_pid) do
    send(owner_pid, {:received, events})
    {:noreply, [], owner_pid}
  end
end
