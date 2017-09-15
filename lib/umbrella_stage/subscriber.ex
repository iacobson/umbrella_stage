defmodule UmbrellaStage.Subscriber do
  @moduledoc false
  require Logger

  def subscribe({consumer_pid, producer_pid, opts}) do
    with  true <- Process.alive?(consumer_pid),
          true <- Process.alive?(producer_pid) do
      Task.start(__MODULE__, :subscribe_stage, [consumer_pid, producer_pid, opts])
    end
  end


  def subscribe_stage(consumer_pid, producer_pid, opts) do
    case GenStage.sync_subscribe(consumer_pid, ([to: producer_pid] ++ opts)) do
      {:ok, _} -> :subscribed
      {:error, error} -> Logger.error("GenStage subscription error: #{inspect(error)}")
      _ -> Logger.error("Cannot subscribe #{inspect(consumer_pid)} to #{inspect(producer_pid)}")
    end
  end
end
