defmodule ConeMediaManager.Repo.Migrations.AddSpotifyAlbumsTable do
  use Ecto.Migration

  def change do
    create table(:albums, primary_key: false) do
      add :id, :string, primary_key: true
      add :album_type, :string, null: false
      add :release_date, :string, null: false
      add :release_date_precision, :string, null: false
      add :total_tracks, :integer, null: false
      add :name, :string, null: false
      add :uri, :string, null: false
      timestamps()
    end
  end
end
