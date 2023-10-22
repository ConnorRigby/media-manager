defmodule ConeMediaManager.Repo.Migrations.AddSpotifyImagesTable do
  use Ecto.Migration

  def change do
    create table(:images, primary_key: false) do
      add :id, :binary_id, primary_key: true
      timestamps()
    end
  end
end
