# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :cone_media_manager,
  ecto_repos: [ConeMediaManager.Repo]

# Configures the endpoint
config :cone_media_manager, ConeMediaManagerWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: ConeMediaManagerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ConeMediaManager.PubSub,
  live_view: [signing_salt: "vBwj3vNq"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :spotify_ex,
  auth_client: Spotify.Authentication,
  user_id: System.fetch_env!("SPOTIFY_CLIENT_ID"),
  client_id: System.fetch_env!("SPOTIFY_CLIENT_ID"),
  secret_key: System.fetch_env!("SPOTIFY_CLIENT_SECRET"),
  callback_url: "http://localhost:4000/oauth/spotify",
  scopes: ["playlist-read-private", "playlist-modify-private", "playlist-modify-public","user-top-read", "user-library-read"]

config :cone_media_manager, Oban,
  engine: Oban.Engines.Lite,
  queues: [default: 10],
  repo: ConeMediaManager.Repo,
  plugins: [Oban.Plugins.Pruner]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
