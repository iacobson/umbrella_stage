# UmbrellaStage

Subscribes GenStage consumers to producers across Elixir Umbrella apps.


## Installation

Add `umbrella_stage` to your list of dependencies in `mix.exs`:

Elixir >= 1.4 required

```elixir
def deps do
  [
    {:umbrella_stage, "~> 0.1.0"}
  ]
end
```

## Usage
1. Configuration  
`use` the `UmbrellaStage` in the GenStages servers. It required 2 arguments:  
- `:type` - is the GenStage type: `:producer`, `:producer_consumer` or `:consumer`  
- `:producers` - required only for **consumers** and **producer_consumers**. It's the list of producers, the consumer (or producer_consumer) will subscribe to, in the following format: `{ProducerName, [subscription_options]}`

2. C
Then call `umbrella_sync_subscribe()` in the GenStage `init`

This version of umbrella_stage implements just the [`GenStage.sync_subscribe/3`](https://hexdocs.pm/gen_stage/GenStage.html#sync_subscribe/3) subscription.

## Examples

### Consumer
```elixir
defmodule MyConsumer do
  use UmbrellaStage,
   type: :consumer,
    producers: [
      {MyProducerConsumer, [max_demand: 10]}
    ]

  def init() do
    umbrella_sync_subscribe()
    .....
  end
end
```

### ProducerConsumer
```
defmodule MyProducerConsumer do
  use UmbrellaStage,
   type: :producer_consumer,
    producers: [
      {MyProducer, [max_demand: 10]}
    ]

  def init() do
    umbrella_sync_subscribe()
    .....
  end
end

```

### Producer
```
defmodule MyProducer do
  use UmbrellaStage,
    type: :producer

  def init() do
    umbrella_sync_subscribe()
    .....
  end
end
```
