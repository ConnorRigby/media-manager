defmodule ConeMediaManager.Spotify.AlbumExternalUrl do
  use Ecto.Schema
  # import Ecto.Changeset

  @primary_key false
  @foreign_key_type :string

  schema "album_external_urls" do
    belongs_to :album, ConeMediaManager.Spotify.Album
    belongs_to :external_url, ConeMediaManager.Spotify.ExternalUrl
    timestamps()
  end
end
