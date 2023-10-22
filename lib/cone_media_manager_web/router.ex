defmodule ConeMediaManagerWeb.Router do
  use ConeMediaManagerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ConeMediaManagerWeb do
    pipe_through :api
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :spotify_auth do
    plug ConeMediaManagerWeb.Plugs.Auth

  end

  # Enable LiveDashboard in development
  if Application.compile_env(:cone_media_manager, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: ConeMediaManagerWeb.Telemetry
    end
  end

  scope "/", ConeMediaManagerWeb do
    pipe_through :browser

    get "/oauth/spotify", SpotifyAuthenticationController, :authenticate
    get "/logged_in", PageController, :logged_in
  end

  scope "/", ConeMediaManagerWeb do
    pipe_through [:browser, :spotify_auth]

    get "/", PageController, :index
  end
end
