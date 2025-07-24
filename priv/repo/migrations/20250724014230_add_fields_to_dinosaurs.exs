defmodule DinosaurBackend.Repo.Migrations.AddFieldsToDinosaurs do
  use Ecto.Migration

  def change do
    alter table(:dinosaurs) do
      add :species, :string
      add :era, :string
      add :latitude, :float
      add :longitude, :float
    end
  end
end
