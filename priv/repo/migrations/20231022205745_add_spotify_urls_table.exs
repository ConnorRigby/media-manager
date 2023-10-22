defmodule ConeMediaManager.Repo.Migrations.AddSpotifyUrlsTable do
  use Ecto.Migration

  def change do
    create table(:external_urls, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :spotify, :string, null: false
      timestamps()
    end

    create table(:album_external_urls, primary_key: false) do
      add :album_id, references(:albums), null: false
      add :external_url_id, references(:external_urls), null: false
      timestamps()
    end

    create index(:album_external_urls, [:album_id, :external_url_id])
  end
end
