defmodule ConeMediaManager.LibraryDownload.AlbumDownload do
  alias Ecto.Multi
  alias ConeMediaManager.Repo
  alias ConeMediaManager.Spotify.{Album, Artist, Track, AlbumArtist, TrackArtist, ExternalUrl, AlbumExternalUrl}

  require Logger

  use Oban.Worker, queue: :default

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"url" => url, "save_file" => save_file}}) do
    System.cmd("python3", [
      "-m", "spotdl",
      "--save-file", save_file,
      "--preload",
      "--sync-without-deleting",
      "--scan-for-songs",
      "--overwrite", "skip",
      "--output", "library/{artist}/{album}/{disc-number}-{track-number}-{title}", url], into: IO.stream())
    :ok
  end
end
