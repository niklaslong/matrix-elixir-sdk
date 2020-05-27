ExUnit.start()
ExUnit.configure(exclude: [external: true])

Application.ensure_all_started(:bypass)
