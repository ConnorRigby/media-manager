defmodule ConeMediaManagerWeb.SpotifyAuthenticationController do
  use ConeMediaManagerWeb, :controller

  def authenticate(conn, params) do
    case Spotify.Authentication.authenticate(conn, params) do
      { :ok, conn } ->
        conn = put_status(conn, 301)
        redirect conn, to: "/logged_in"
      { :error, _reason, conn } -> conn
    end

  end
end
