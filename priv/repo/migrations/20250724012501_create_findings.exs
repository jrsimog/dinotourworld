defmodule DinosaurBackend.Repo.Migrations.CreateFindings do
  use Ecto.Migration

  def change do
    create table(:findings) do
      add :year, :integer
      add :source, :string
      add :dinosaur_id, references(:dinosaurs, on_delete: :nothing)
      add :location_id, references(:locations, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:findings, [:dinosaur_id])
    create index(:findings, [:location_id])
  end
end
