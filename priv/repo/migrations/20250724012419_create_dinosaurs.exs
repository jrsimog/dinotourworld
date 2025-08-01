defmodule DinosaurBackend.Repo.Migrations.CreateDinosaurs do
  use Ecto.Migration

  def change do
    create table(:dinosaurs) do
      add :name, :string
      add :description, :text

      timestamps(type: :utc_datetime)
    end
  end
end
