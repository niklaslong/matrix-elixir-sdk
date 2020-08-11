ExUnit.start()
ExUnit.configure(exclude: [external: true])

Application.ensure_all_started(:bypass)
Application.put_env(:matrix_sdk, :http_client, MatrixSDK.HTTPClientMock)
