defmodule ConeMediaManagerWeb.PageController do
  use ConeMediaManagerWeb, :controller

  def index(conn, _params) do
    send_resp(conn, 200, "index\n" <> inspect(conn, limit: :infinity, pretty: true))
  end

  def logged_in(conn, _params) do
    %{"cookies" => conn.cookies}
    |> ConeMediaManager.LibrarySync.new()
    |> Oban.insert!(queue: :default)

    send_resp(conn, 200, "sync started")
  end
end
