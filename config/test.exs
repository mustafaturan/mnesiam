use Mix.Config

config :mnesiam,
  stores: [
    Mnesiam.Support.SampleStore
  ],
  table_load_timeout: 600_000
