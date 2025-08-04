defmodule DinosaurBackend.OpenStreetMap.Service do
  @moduledoc """
  Service layer for OpenStreetMap operations.
  
  This module provides a high-level interface for geocoding operations,
  with caching, error handling, and business logic specific to the application.
  """

  alias DinosaurBackend.OpenStreetMap.Client

  defp get_default_client do
    Application.get_env(:dinosaur_backend, :openstreetmap, [])
    |> Keyword.get(:client, Client)
  end

  defstruct [:client]

  @type t :: %__MODULE__{client: module()}

  def new(client \\ nil) do
    client = client || get_default_client()
    %__MODULE__{client: client}
  end

  @doc """
  Find coordinates for a given address.
  
  Returns the first result with highest confidence.
  """
  def find_coordinates(service \\ new(), address) when is_binary(address) do
    case service.client.geocode(address, limit: 1) do
      {:ok, [result | _]} ->
        {:ok, %{lat: result.lat, lon: result.lon}}
      
      {:ok, []} ->
        {:error, "Address not found"}
      
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Find address for given coordinates.
  """
  def find_address(service \\ new(), coordinates) do
    case service.client.reverse_geocode(coordinates) do
      {:ok, result} ->
        {:ok, result.display_name}
      
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Find coordinates for multiple addresses in batch.
  
  Returns a map with addresses as keys and results as values.
  """
  def batch_geocode(service \\ new(), addresses) when is_list(addresses) do
    addresses
    |> Task.async_stream(
      fn address ->
        {address, find_coordinates(service, address)}
      end,
      max_concurrency: 5,
      timeout: 10_000
    )
    |> Enum.reduce(%{}, fn {:ok, {address, result}}, acc ->
      Map.put(acc, address, result)
    end)
  end

  @doc """
  Search for places near given coordinates within a radius.
  
  ## Parameters
  - coordinates: %{lat: float(), lon: float()}
  - query: search term
  - radius_km: search radius in kilometers (default: 10)
  """
  def search_nearby(coordinates, query, radius_km \\ 10) do
    search_nearby(new(), coordinates, query, radius_km)
  end

  def search_nearby(service, coordinates, query, radius_km) do
    # Calculate bounding box based on radius
    viewbox = calculate_viewbox(coordinates, radius_km)
    
    opts = [
      viewbox: viewbox,
      bounded: true,
      limit: 20
    ]
    
    case service.client.search(query, opts) do
      {:ok, results} ->
        filtered_results = 
          results
          |> Enum.map(&add_distance(&1, coordinates))
          |> Enum.filter(fn result -> result.distance_km <= radius_km end)
          |> Enum.sort_by(& &1.distance_km)
        
        {:ok, filtered_results}
      
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Validate if coordinates are within reasonable bounds.
  """
  def valid_coordinates?(%{lat: lat, lon: lon}) 
      when is_number(lat) and is_number(lon) do
    lat >= -90 and lat <= 90 and lon >= -180 and lon <= 180
  end
  
  def valid_coordinates?(_), do: false

  defp calculate_viewbox(%{lat: lat, lon: lon}, radius_km) do
    lat_deg_per_km = 1 / 111.0
    lon_deg_per_km = 1 / (111.0 * :math.cos(lat * :math.pi / 180))
    
    lat_offset = radius_km * lat_deg_per_km
    lon_offset = radius_km * lon_deg_per_km
    
    "#{lon - lon_offset},#{lat + lat_offset},#{lon + lon_offset},#{lat - lat_offset}"
  end

  defp add_distance(result, center_coords) do
    distance = haversine_distance(
      %{lat: result.lat, lon: result.lon},
      center_coords
    )
    
    Map.put(result, :distance_km, distance)
  end

  defp haversine_distance(%{lat: lat1, lon: lon1}, %{lat: lat2, lon: lon2}) do
    r = 6371
    
    dlat = (lat2 - lat1) * :math.pi / 180
    dlon = (lon2 - lon1) * :math.pi / 180
    
    a = :math.sin(dlat / 2) * :math.sin(dlat / 2) +
        :math.cos(lat1 * :math.pi / 180) * :math.cos(lat2 * :math.pi / 180) *
        :math.sin(dlon / 2) * :math.sin(dlon / 2)
    
    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))
    
    r * c
  end
end