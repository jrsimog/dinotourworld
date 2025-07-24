defmodule DinosaurBackend.Locations.Location do
  use Ecto.Schema
  import Ecto.Changeset

  alias DinosaurBackend.Findings.Finding

  schema "locations" do
    field :city, :string
    field :country, :string
    field :latitude, :float
    field :longitude, :float

    has_many :findings, Finding

    timestamps()
  end

  def changeset(location, attrs) do
    location
    |> cast(attrs, [:city, :country, :latitude, :longitude])
    |> validate_required([:city, :country, :latitude, :longitude])
  end
end
