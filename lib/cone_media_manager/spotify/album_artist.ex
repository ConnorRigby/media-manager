defmodule ConeMediaManager.Spotify.AlbumArtist do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :string

  schema "album_artists" do
    belongs_to :album, ConeMediaManager.Spotify.Album
    belongs_to :artist, ConeMediaManager.Spotify.Artist
    timestamps()
  end

  def changeset(spotify_album_artist, attrs \\ %{}) do
    spotify_album_artist
    |> cast(attrs, [
      :album_id,
      :artist_id
    ])
  end
end
