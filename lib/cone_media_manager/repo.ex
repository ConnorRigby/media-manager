defmodule ConeMediaManager.Repo do
  use Ecto.Repo,
    otp_app: :cone_media_manager,
    adapter: Ecto.Adapters.SQLite3
end
