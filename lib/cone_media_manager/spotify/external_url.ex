defmodule ConeMediaManager.Spotify.ExternalUrl do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :string

  schema "external_urls" do
    field :spotify, :string
    timestamps()
  end

  def changeset(external_url, attrs \\ %{}) do
    external_url
    |> cast(attrs, [:spotify])
  end

end
