import Config

config :tesla, adapter: Tesla.Adapter.Mint

import_config "#{Mix.env()}.exs"
