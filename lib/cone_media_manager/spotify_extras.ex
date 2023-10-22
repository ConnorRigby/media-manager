defmodule SpotifyExtras do
  alias Spotify.Client
  use Spotify.Responder
  import Spotify.Helpers

  def my_albums(conn, params \\ %{}) do
    conn |> Client.get(my_albums_url(params)) |> handle_response
  end

  def my_albums_url(params), do: "https://api.spotify.com/v1/me/albums" <> query_string(params)

  def build_response(body) do
    body
  end
end
