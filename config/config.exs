import Config

config :matrix_sdk, http_client: MatrixSDK.HTTPClient
config :tesla, adapter: Tesla.Adapter.Hackney

import_config "#{Mix.env()}.exs"
