# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :auth_api,
  ecto_repos: [AuthApi.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configures the endpoint
config :auth_api, AuthApiWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: AuthApiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: AuthApi.PubSub,
  live_view: [signing_salt: "l/cLzEbE"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :auth_api, AuthApiWeb.Auth.Guardian,
  issuer: "auth_api",
  secret_key: "6Xi95/Voy4/gp09A0TQdqxgk6/R3NOlTs/y74SpB0IYM+FaxkN3PeVikd8XAB614"

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :guardian, Guardian.DB,
    repo: AuthApi.Repo,
    schema_name: "guardian_tokens",
    sweep_interval: 60

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
