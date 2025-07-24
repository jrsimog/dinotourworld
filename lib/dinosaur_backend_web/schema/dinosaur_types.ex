defmodule DinosaurBackendWeb.Schema.DinosaurTypes do
  use Absinthe.Schema.Notation

  @desc "A dinosaur"
  object :dinosaur do
    field :id, :id
    field :name, :string
    field :description, :string
    field :species, :string
    field :era, :string
    field :latitude, :float
    field :longitude, :float
    
    @desc "Locations where this dinosaur was found"
    field :locations, list_of(:location) do
      resolve fn dinosaur, _, _ ->
        # Preload locations through findings
        dinosaur = DinosaurBackend.Repo.preload(dinosaur, [findings: :location])
        locations = Enum.map(dinosaur.findings, & &1.location)
        {:ok, locations}
      end
    end
  end

  @desc "A location where dinosaurs were found"
  object :location do
    field :id, :id
    field :city, :string
    field :country, :string
    field :latitude, :float
    field :longitude, :float
  end

  @desc "A finding linking a dinosaur to a location"
  object :finding do
    field :id, :id
    field :year, :integer
    field :source, :string
    field :dinosaur, :dinosaur
    field :location, :location
  end
end