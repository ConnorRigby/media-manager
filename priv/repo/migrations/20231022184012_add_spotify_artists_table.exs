defmodule ConeMediaManager.Repo.Migrations.AddSpotifyArtistsTable do
  use Ecto.Migration

  def change do
    create table(:artists, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string, null: false
      timestamps()
    end

    create table(:album_artists, primary_key: false) do
      add :album_id, references(:albums), null: false
      add :artist_id, references(:artists), null: false
      timestamps()
    end

    create index(:album_artists, [:album_id, :artist_id])

    create table(:track_artists, primary_key: false) do
      add :track_id, references(:tracks), null: false
      add :artist_id, references(:artists), null: false
      timestamps()
    end

    create index(:track_artists, [:track_id, :artist_id])
  end
end
