defmodule ConeMediaManager.Spotify.Track do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :string, autogenerate: false}
  @foreign_key_type :string

  schema "tracks" do
    belongs_to :album, ConeMediaManager.Spotify.Album
    many_to_many :artists, ConeMediaManager.Spotify.Artist, join_through: ConeMediaManager.Spotify.TrackArtist
    field :name, :string
    field :disc_number, :integer
    field :duration_ms, :integer
    field :track_number, :integer
    timestamps()
  end

  def changeset(artist, attrs \\ %{}) do
    artist
    |> cast(attrs, [:id, :name, :disc_number, :duration_ms, :track_number])
  end
end
