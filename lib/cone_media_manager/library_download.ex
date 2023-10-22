defmodule ConeMediaManager.LibraryDownload do
  alias Ecto.Multi
  alias ConeMediaManager.Repo
  alias ConeMediaManager.Spotify.{Album, Artist, Track, AlbumArtist, TrackArtist, ExternalUrl, AlbumExternalUrl}

  require Logger

  use Oban.Worker, queue: :default

  @impl Oban.Worker
  def perform(%Oban.Job{args: _args}) do
    albums = Repo.all(Album) |> Repo.preload(:external_urls)
    albums_with_urls = Enum.map(albums, fn album -> {album.id, album.external_urls} end)

      Enum.map(albums_with_urls, fn {album_id, external_urls} ->
        Enum.reduce(external_urls, 0, fn %{spotify: url}, acc ->
          ConeMediaManager.LibraryDownload.AlbumDownload.new(%{"url" => url, "save_file" => "spotdl-save-#{album_id}-#{acc}.spotdl"}, schedule_in: 1)
          |> Oban.insert()
          acc + 1
        end)
      end)

    :ok
  end
end
