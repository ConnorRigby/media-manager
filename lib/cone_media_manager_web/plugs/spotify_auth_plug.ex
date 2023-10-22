defmodule ConeMediaManagerWeb.Plugs.Auth do
  require Logger

  def init(default), do: default

  def call(conn, _default) do
    unless Spotify.Authentication.authenticated?(conn) do
      Logger.info("redirecting for auth")
      Phoenix.Controller.redirect conn, external: Spotify.Authorization.url
    else
      conn
    end
  end
end
