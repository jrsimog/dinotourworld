defmodule DinosaurBackendWeb.Schema do
  use Absinthe.Schema

  alias DinosaurBackendWeb.Resolvers

  import_types DinosaurBackendWeb.Schema.DinosaurTypes

  query do
    @desc "Get all dinosaurs with optional filters"
    field :dinosaurs, list_of(:dinosaur) do
      @desc "Filter by dinosaur name"
      arg :name, :string
      @desc "Filter by city where dinosaur was found"
      arg :city, :string
      
      resolve &Resolvers.Dinosaur.list_dinosaurs/3
    end

    @desc "Get a single dinosaur by ID"
    field :dinosaur, :dinosaur do
      arg :id, non_null(:id)
      resolve &Resolvers.Dinosaur.get_dinosaur/3
    end
  end
end