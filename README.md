# UmbrellaStage

Subscribes GenStage consumers to producers across Elixir Umbrella apps.

## Installation

Adding `umbrella_stage` to your list of dependencies in `mix.exs`:

Elixir >= 1.4 required

```elixir
def deps do
  [
    {:umbrella_stage, "~> 0.1.0"}
  ]
end§
```

## Usage
`use` the `UmbrellaStage` in the GenStages servers. It required 2 arguments:  
- `:type` - is the GenStage type: `:producer`, `:producer_consumer` or `:consumer`  
- `:producers` - required only for consumers and producer_consumers. It's the list of producers, the consumer will subscribe to, in the following format:  
`{ProducerName, [subscription_options]}`  

Then call `sync_subscribe()` in the GenStage `init`

### Example Consumer
```
  use Borg.UmbrellaStage,
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

## TODO: 
[] Configuration file do disable the subscription.

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/umbrella_stage](https://hexdocs.pm/umbrella_stage).

