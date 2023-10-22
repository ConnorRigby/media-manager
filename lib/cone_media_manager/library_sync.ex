defmodule ConeMediaManager.LibrarySync do
  alias Ecto.Multi
  alias ConeMediaManager.Repo
  alias ConeMediaManager.Spotify.{Album, Artist, Track, AlbumArtist, TrackArtist, ExternalUrl, AlbumExternalUrl}

  require Logger

  use Oban.Worker, queue: :default

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    with {:ok, conn} <- build_plug(args),
         {:ok, my_albums} <- SpotifyExtras.my_albums(conn, args["params"] || %{}),
         :ok <- process_albums(my_albums) do
      case my_albums["items"] do
        [] ->
          Logger.info("sync complete")
          :ok

        [_ | _] ->
          enqueue_next_job(%{
            "cookies" => conn.cookies,
            "params" => %{
              "offset" => my_albums["offset"] + my_albums["limit"],
              "limit" => my_albums["limit"]
            }
          })
      end
    end
  end

  def build_plug(args) do
    %Plug.Conn{cookies: args["cookies"], req_cookies: %{}}
    |> Spotify.Authentication.refresh()
  end

  def process_albums(my_albums) do
    # multi = Enum.reduce(my_albums["items"], Multi.new(), &process_album/2)
    Enum.map(my_albums["items"], fn album ->
      multi = process_album(album, Multi.new())

      case Repo.transaction(multi) do
        {:ok, _} -> Logger.info("process_albums complete")
        {:error, _, _, _} = error -> Logger.error(%{process_albums: error})
      end
    end)

    :ok
  end

  def process_album(%{"album" => album}, multi) do
    Logger.debug("start process_album")

    multi =
      Enum.reduce(album["artists"], multi, fn artist, multi ->
        Multi.run(multi, {:artist, artist["id"]}, fn repo, _ ->
          case repo.get(Artist, artist["id"]) do
            nil ->
              Logger.debug(%{insert_artist: artist})
              repo.insert(Artist.changeset(%Artist{}, artist))

            %Artist{} = db_artist ->
              Logger.debug(%{update_artist: db_artist})
              repo.update(Artist.changeset(db_artist, artist))
          end
        end)
      end)
      |> Multi.run({:album, album["id"]}, fn repo, _ ->
        case repo.get(Album, album["id"]) do
          nil ->
            Logger.debug(%{insert_album: album})
            repo.insert(Album.changeset(%Album{}, album))

          %Album{} = db_album ->
            Logger.debug(%{update_album: album})
            repo.update(Album.changeset(db_album, album))
        end
      end)

    multi =
      if external_url = album["external_urls"]["spotify"] do
        Multi.run(multi, {:external_url, external_url}, fn repo, _ ->
          db_external_url =
            case repo.get_by(ExternalUrl, spotify: external_url) do
              %ExternalUrl{} = db_external_url -> db_external_url
              nil -> repo.insert!(ExternalUrl.changeset(%ExternalUrl{}, %{spotify: external_url}))
            end

          repo.insert(%AlbumExternalUrl{
            album_id: album["id"],
            external_url_id: db_external_url.id
          })
        end)
      else
        multi
      end

    # enumerate artists again
    multi =
      Enum.reduce(album["artists"], multi, fn artist, multi ->
        Multi.run(multi, {:album_artist, artist["id"]}, fn repo, _ ->
          album_artist = %{album_id: album["id"], artist_id: artist["id"]}

          case Repo.get_by(AlbumArtist, album_id: album["id"], artist_id: artist["id"]) do
            nil ->
              Logger.debug(%{insert_album_artist: album_artist})
              repo.insert(AlbumArtist.changeset(%AlbumArtist{}, album_artist))

            %AlbumArtist{} = db_album_artist ->
              {:ok, db_album_artist}
              # Logger.debug(%{update_album_artist: album_artist})
              # repo.update(AlbumArtist.changeset(db_album_artist, album_artist))
          end
        end)
      end)

    # enumerate tracks for artists
    multi =
      Enum.reduce(album["tracks"]["items"], multi, fn track, multi ->
        Enum.reduce(track["artists"], multi, fn artist, multi ->
          Multi.run(multi, {:artist_from_track, track["id"] <> "-" <> artist["id"]}, fn repo, _ ->
            case repo.get(Artist, artist["id"]) do
              nil ->
                Logger.debug(%{insert_artist_from_track: artist})
                repo.insert(Artist.changeset(%Artist{}, artist))

              %Artist{} = db_artist ->
                Logger.debug(%{update_artist_from_track: db_artist})
                repo.update(Artist.changeset(db_artist, artist))
            end
          end)
        end)
      end)

    # enumerate tracks
    multi =
      Enum.reduce(album["tracks"]["items"], multi, fn track, multi ->
        Multi.run(multi, {:album_track, track["id"]}, fn repo, _ ->
          case Repo.get(Track, track["id"]) do
            nil ->
              Logger.debug(%{insert_track: track})
              repo.insert(Track.changeset(%Track{album_id: album["id"]}, track))

            %Track{} = db_track ->
              Logger.debug(%{update_track: track})
              repo.update(Track.changeset(db_track, track))
          end
        end)
      end)

    # enumerate tracks again for artists
    multi =
      Enum.reduce(album["tracks"]["items"], multi, fn track, multi ->
        Enum.reduce(track["artists"], multi, fn artist, multi ->
          Multi.run(multi, {:track_artist, track["id"] <> "-" <> artist["id"]}, fn repo, _ ->
            track_artist = %{track_id: track["id"], artist_id: artist["id"]}

            case repo.get_by(TrackArtist, track_id: track["id"], artist_id: artist["id"]) do
              nil ->
                Logger.debug(%{insert_track_artist: track_artist})
                repo.insert(TrackArtist.changeset(%TrackArtist{}, track_artist))

              %TrackArtist{} = db_track_artist ->
                {:ok, db_track_artist}
                # Logger.debug(%{update_track_artist: track_artist})
                # repo.update(TrackArtist.changeset(db_track_artist, track_artist))
            end
          end)
        end)
      end)

    Logger.info("end process_album")
    multi
  end

  def enqueue_next_job(args) do
    Logger.info(%{enqueue_next_job: args})

    new(args, schedule_in: 1)
    |> Oban.insert()

    :ok
  end
end
