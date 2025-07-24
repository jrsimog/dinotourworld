defmodule DinosaurBackend.Findings.Finding do
  use Ecto.Schema
  import Ecto.Changeset

  alias DinosaurBackend.Dinosaurs.Dinosaur
  alias DinosaurBackend.Locations.Location

  schema "findings" do
    field :year, :integer
    field :source, :string

    belongs_to :dinosaur, Dinosaur
    belongs_to :location, Location

    timestamps()
  end

  def changeset(finding, attrs) do
    finding
    |> cast(attrs, [:dinosaur_id, :location_id, :year, :source])
    |> validate_required([:dinosaur_id, :location_id, :year, :source])
  end
end
