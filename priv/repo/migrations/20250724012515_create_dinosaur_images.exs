defmodule DinosaurBackend.Repo.Migrations.CreateDinosaurImages do
  use Ecto.Migration

  def change do
    create table(:dinosaur_images) do
      add :url, :string
      add :caption, :text
      add :dinosaur_id, references(:dinosaurs, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:dinosaur_images, [:dinosaur_id])
  end
end
