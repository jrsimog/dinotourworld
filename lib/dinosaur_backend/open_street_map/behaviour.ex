defmodule DinosaurBackend.OpenStreetMap.Behaviour do
  @moduledoc """
  Behaviour for OpenStreetMap API clients.
  
  This behaviour defines the contract for interacting with OpenStreetMap services,
  including geocoding (address to coordinates) and reverse geocoding (coordinates to address).
  """

  @type coordinates :: %{lat: float(), lon: float()}
  @type address :: String.t()
  @type geocode_result :: %{
    lat: float(),
    lon: float(),
    display_name: String.t(),
    address: map()
  }
  @type error :: {:error, String.t()}

  @doc """
  Geocode an address to coordinates.
  
  ## Parameters
  - address: The address string to geocode
  - options: Additional options (limit, format, etc.)
  
  ## Returns
  - {:ok, [geocode_result()]} on success
  - {:error, String.t()} on failure
  """
  @callback geocode(address(), keyword()) :: {:ok, [geocode_result()]} | error()

  @doc """
  Reverse geocode coordinates to an address.
  
  ## Parameters
  - coordinates: Map with lat and lon keys
  - options: Additional options (format, zoom, etc.)
  
  ## Returns
  - {:ok, geocode_result()} on success
  - {:error, String.t()} on failure
  """
  @callback reverse_geocode(coordinates(), keyword()) :: {:ok, geocode_result()} | error()

  @doc """
  Search for places by name with optional bounding box.
  
  ## Parameters
  - query: Search query string
  - options: Additional options (limit, bounded, viewbox, etc.)
  
  ## Returns
  - {:ok, [geocode_result()]} on success
  - {:error, String.t()} on failure
  """
  @callback search(String.t(), keyword()) :: {:ok, [geocode_result()]} | error()
end