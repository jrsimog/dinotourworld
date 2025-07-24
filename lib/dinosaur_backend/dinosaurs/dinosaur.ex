defmodule DinosaurBackend.Dinosaurs.Dinosaur do
  use Ecto.Schema
  import Ecto.Changeset

  alias DinosaurBackend.Findings.Finding
  alias DinosaurBackend.Dinosaurs.Image

  schema "dinosaurs" do
    field :name, :string
    field :description, :string
    field :species, :string
    field :era, :string
    field :latitude, :float
    field :longitude, :float

    has_many :findings, Finding
    has_many :images, Image

    timestamps()
  end

  def changeset(dino, attrs) do
    dino
    |> cast(attrs, [:name, :description, :species, :era, :latitude, :longitude])
    |> validate_required([:name, :description, :species, :era, :latitude, :longitude])
  end
end
