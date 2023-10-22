defmodule ConeMediaManager.Spotify.TrackArtist do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :string

  schema "track_artists" do
    belongs_to :track, ConeMediaManager.Spotify.Track
    belongs_to :artist, ConeMediaManager.Spotify.Artist
    timestamps()
  end

  def changeset(spotify_track_artist, attrs \\ %{}) do
    spotify_track_artist
    |> cast(attrs, [
      :track_id,
      :artist_id
    ])
  end
end
