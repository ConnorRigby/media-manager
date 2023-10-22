defmodule ConeMediaManager.Spotify.Album do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}

  schema "albums" do
    many_to_many :artists, ConeMediaManager.Spotify.Artist, join_through: ConeMediaManager.Spotify.AlbumArtist
    many_to_many :external_urls, ConeMediaManager.Spotify.ExternalUrl, join_through: ConeMediaManager.Spotify.AlbumExternalUrl
    field(:album_type, :string)
    field(:release_date, :string)
    field(:release_date_precision, :string)
    field(:total_tracks, :integer)
    field(:name, :string)
    field(:uri, :string)
    timestamps()
  end

  def changeset(spotify_album, attrs \\ %{}) do
    spotify_album
    |> cast(attrs, [
      :id,
      :album_type,
      :release_date,
      :release_date_precision,
      :total_tracks,
      :name,
      :uri
    ])
  end
end
