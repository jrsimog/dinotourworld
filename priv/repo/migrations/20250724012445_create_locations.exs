defmodule DinosaurBackend.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :city, :string
      add :country, :string
      add :latitude, :float
      add :longitude, :float

      timestamps(type: :utc_datetime)
    end
  end
end
