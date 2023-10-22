defmodule ConeMediaManager.Repo.Migrations.AddSpotifyTracksTable do
  use Ecto.Migration

  def change do
    create table(:tracks, primary_key: false) do
      add :id, :string, primary_key: true
      add :album_id, references(:albums), null: false

      add :name, :string, null: false
      add :disc_number, :integer, null: false
      add :duration_ms, :integer, null: false
      add :track_number, :integer, null: false

      timestamps()
    end

  end
end
