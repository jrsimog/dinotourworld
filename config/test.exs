import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :dinosaur_backend, DinosaurBackend.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "dinosaur_backend_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :dinosaur_backend, DinosaurBackendWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "+V2wCDnhfByhazmQrKSeCnyopB+v8iDLy5T7sp5U9mGLNCB2Gj0zbOFkddWMjQYa",
  server: false

# In test we don't send emails
config :dinosaur_backend, DinosaurBackend.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# API Authentication tokens for testing
config :dinosaur_backend, :api_tokens, [
  "dev_token_12345",
  "test_token_67890"
]

# Configure OpenStreetMap to use mock in tests
config :dinosaur_backend, :openstreetmap,
  client: DinosaurBackend.Mocks.OpenStreetMapMock
