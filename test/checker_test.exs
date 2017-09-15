defmodule UmbrellaStage.CheckerTest do
  use ExUnit.Case
  alias UmbrellaStage.Checker
  alias UmbrellaStage.GenStageTest

  setup do
    Registry.unregister(Registry.Subscriptions, :producers)
    Registry.unregister(Registry.Subscriptions, :consumers)
    :ok
  end

  describe "one consumer that should subscribe to one producer" do
    setup do
      producer_reg = [{:producers, TestProducer}]
      consumer_reg = [{:consumers, {TestProducer, [max_demand: 3]}}]
      {:ok, producer_reg: producer_reg, consumer_reg: consumer_reg}
    end

    test "returns the consumer producer pair when both started",
    %{producer_reg: producer_reg, consumer_reg: consumer_reg} do

      {:ok, producer_pid} = GenStageTest.start_link(TestProducer, :producer, producer_reg)
      assert Checker.check_producer_subscribers(producer_pid, TestProducer) == []

      {:ok, consumer_pid} = GenStageTest.start_link(TestConsumer, :consumer, consumer_reg)
      assert Checker.check_consumer_subscriptions(consumer_pid) == [{consumer_pid, producer_pid, [max_demand: 3]}]
    end

    test "order of the start should not matter",
    %{producer_reg: producer_reg, consumer_reg: consumer_reg} do

      {:ok, consumer_pid} = GenStageTest.start_link(TestConsumer, :consumer, consumer_reg)
      assert Checker.check_consumer_subscriptions(consumer_pid) == []

      {:ok, producer_pid} = GenStageTest.start_link(TestProducer, :producer, producer_reg)
      assert Checker.check_producer_subscribers(producer_pid, TestProducer) == [{consumer_pid, producer_pid, [max_demand: 3]}]
    end
  end

  describe "2 producers, 2 consumers, one producer-consumer" do
    test "returns the consumer producer pairs when the pairs are started" do
      producer_1_reg = [{:producers, TestProducerOne}]
      producer_2_reg = [{:producers, TestProducerTwo}]

      producer_consumer_reg = [
        {:producers, TestProducerConsumer},
        {:consumers, {TestProducerOne, [max_demand: 3]}},
        {:consumers, {TestProducerTwo, [max_demand: 3]}}
      ]

      consumer_1_reg = [{:consumers, {TestProducerConsumer, [max_demand: 3]}}]
      consumer_2_reg = [{:consumers, {TestProducerConsumer, [max_demand: 3]}}]

      {:ok, producer_1_pid} = GenStageTest.start_link(TestProducerOne, :producer, producer_1_reg)
      assert Checker.check_producer_subscribers(producer_1_pid, TestProducerOne) == []

      {:ok, producer_2_pid} = GenStageTest.start_link(TestProducerTwo, :producer, producer_2_reg)
      assert Checker.check_producer_subscribers(producer_2_pid, TestProducerTwo) == []

      {:ok, consumer_1_pid} = GenStageTest.start_link(TestConsumerOne, :consumer, consumer_1_reg)
      assert Checker.check_consumer_subscriptions(consumer_1_pid) == []

      {:ok, producer_consumer_pid} = GenStageTest.start_link(TestProducerConsumer, :producer_consumer, producer_consumer_reg)
      as_producer = Checker.check_producer_subscribers(producer_consumer_pid, TestProducerConsumer)
      as_consumer = Checker.check_consumer_subscriptions(producer_consumer_pid)
      assert Enum.sort(as_producer ++ as_consumer) == [
        {producer_consumer_pid, producer_1_pid, [max_demand: 3]},
        {producer_consumer_pid, producer_2_pid, [max_demand: 3]},
        {consumer_1_pid, producer_consumer_pid, [max_demand: 3]}
      ] |> Enum.sort()

      {:ok, consumer_2_pid} = GenStageTest.start_link(TestConsumerTwo, :consumer, consumer_2_reg)
      assert Checker.check_consumer_subscriptions(consumer_2_pid) == [{consumer_2_pid, producer_consumer_pid, [max_demand: 3]}]
    end
  end

  describe "2 parallel GenStages" do
    test "returns the consumer producer pairs for each GenStage" do
      producer_1_reg = [{:producers, TestProducerOne}]
      producer_2_reg = [{:producers, TestProducerTwo}]
      consumer_1_reg = [{:consumers, {TestProducerOne, [max_demand: 3]}}]
      consumer_2_reg = [{:consumers, {TestProducerTwo, [max_demand: 3]}}]

      {:ok, producer_1_pid} = GenStageTest.start_link(TestProducerOne, :producer, producer_1_reg)
      assert Checker.check_producer_subscribers(producer_1_pid, TestProducerOne) == []

      {:ok, consumer_2_pid} = GenStageTest.start_link(TestConsumerTwo, :consumer, consumer_2_reg)
      assert Checker.check_consumer_subscriptions(consumer_2_pid) == []

      {:ok, consumer_1_pid} = GenStageTest.start_link(TestConsumerOne, :consumer, consumer_1_reg)
      assert Checker.check_consumer_subscriptions(consumer_1_pid) == [{consumer_1_pid, producer_1_pid, [max_demand: 3]}]

      {:ok, producer_2_pid} = GenStageTest.start_link(TestProducerTwo, :producer, producer_2_reg)
      assert Checker.check_producer_subscribers(producer_2_pid, TestProducerTwo) == [{consumer_2_pid, producer_2_pid, [max_demand: 3]}]
    end
  end
end

defmodule UmbrellaStage.GenStageTest do
  use GenStage

  def start_link(name, type, registers) do
    GenStage.start_link(__MODULE__, {type, registers}, name: name)
  end

  def init({type, registers}) do
    Enum.each(registers, &register/1)
    {type, :no_state}
  end

  defp register({key, value}) do
    Registry.register(Registry.Subscriptions, key, value)
  end
end
