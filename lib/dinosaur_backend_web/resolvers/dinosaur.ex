defmodule DinosaurBackendWeb.Resolvers.Dinosaur do
  import Ecto.Query
  alias DinosaurBackend.Repo
  alias DinosaurBackend.Dinosaurs.Dinosaur
  alias DinosaurBackend.Findings.Finding
  alias DinosaurBackend.Locations.Location

  def list_dinosaurs(_root, args, _info) do
    dinosaurs = search_dinosaurs(args)
    {:ok, dinosaurs}
  end

  def get_dinosaur(_root, %{id: id}, _info) do
    case Repo.get(Dinosaur, id) do
      nil -> {:error, "Dinosaur not found"}
      dinosaur -> {:ok, dinosaur}
    end
  end

  defp search_dinosaurs(args) do
    base_query = 
      from d in Dinosaur,
        left_join: f in Finding, on: f.dinosaur_id == d.id,
        left_join: l in Location, on: l.id == f.location_id,
        distinct: d.id

    query = apply_filters(base_query, args)
    
    Repo.all(query)
  end

  defp apply_filters(query, args) do
    query
    |> filter_by_name(args[:name])
    |> filter_by_city(args[:city])
  end

  defp filter_by_name(query, nil), do: query
  defp filter_by_name(query, name) when is_binary(name) do
    from [d, f, l] in query,
      where: ilike(d.name, ^"%#{name}%")
  end

  defp filter_by_city(query, nil), do: query
  defp filter_by_city(query, city) when is_binary(city) do
    from [d, f, l] in query,
      where: ilike(l.city, ^"%#{city}%")
  end
end