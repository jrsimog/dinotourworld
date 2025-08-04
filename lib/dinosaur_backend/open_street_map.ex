defmodule DinosaurBackend.OpenStreetMap do
  @moduledoc """
  Main module for OpenStreetMap integration.
  
  This module provides a unified interface for all OpenStreetMap operations
  and serves as the primary entry point for geocoding services.
  """

  alias DinosaurBackend.OpenStreetMap.Service

  @doc """
  Get coordinates for an address.
  
  ## Examples
  
      iex> DinosaurBackend.OpenStreetMap.geocode("Madrid, Spain")
      {:ok, %{lat: 40.4168, lon: -3.7038}}
      
      iex> DinosaurBackend.OpenStreetMap.geocode("Invalid Address")
      {:error, "Address not found"}
  """
  defdelegate find_coordinates(address), to: Service

  @doc """
  Get address for coordinates.
  
  ## Examples
  
      iex> DinosaurBackend.OpenStreetMap.reverse_geocode(%{lat: 40.4168, lon: -3.7038})
      {:ok, "Madrid, Community of Madrid, Spain"}
  """
  defdelegate find_address(coordinates), to: Service

  @doc """
  Batch geocode multiple addresses.
  
  ## Examples
  
      iex> addresses = ["Madrid, Spain", "Barcelona, Spain"]
      iex> DinosaurBackend.OpenStreetMap.batch_geocode(addresses)
      %{
        "Madrid, Spain" => {:ok, %{lat: 40.4168, lon: -3.7038}},
        "Barcelona, Spain" => {:ok, %{lat: 41.3851, lon: 2.1734}}
      }
  """
  defdelegate batch_geocode(addresses), to: Service

  @doc """
  Search for places near given coordinates.
  
  ## Examples
  
      iex> coords = %{lat: 40.4168, lon: -3.7038}
      iex> DinosaurBackend.OpenStreetMap.search_nearby(coords, "museum", 5)
      {:ok, [%{lat: 40.4138, lon: -3.6921, display_name: "Museo Nacional del Prado", distance_km: 1.2}]}
  """
  defdelegate search_nearby(coordinates, query, radius_km \\ 10), to: Service

  @doc """
  Validate if coordinates are within reasonable bounds.
  
  ## Examples
  
      iex> DinosaurBackend.OpenStreetMap.valid_coordinates?(%{lat: 40.4168, lon: -3.7038})
      true
      
      iex> DinosaurBackend.OpenStreetMap.valid_coordinates?(%{lat: 91, lon: 0})
      false
  """
  defdelegate valid_coordinates?(coordinates), to: Service

  @doc """
  Create a service instance with custom client (useful for testing).
  """
  defdelegate new_service(client \\ nil), to: Service, as: :new
end