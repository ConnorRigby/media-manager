defmodule ConeMediaManager.Spotify.Artist do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :string, autogenerate: false}

  schema "artists" do
    field :name, :string
    timestamps()
  end

  def changeset(artist, attrs \\ %{}) do
    artist
    |> cast(attrs, [:id, :name])
  end
end
