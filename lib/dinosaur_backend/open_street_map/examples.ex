defmodule DinosaurBackend.OpenStreetMap.Examples do
  @moduledoc """
  Examples of how to use the OpenStreetMap integration.
  
  This module contains example usage patterns and is meant for
  documentation and testing purposes.
  """

  alias DinosaurBackend.OpenStreetMap

  @doc """
  Example: Find coordinates for an address
  """
  def example_geocode do
    case OpenStreetMap.find_coordinates("Madrid, Spain") do
      {:ok, %{lat: lat, lon: lon}} ->
        IO.puts("Madrid is located at: #{lat}, #{lon}")
        {:ok, %{lat: lat, lon: lon}}
      
      {:error, reason} ->
        IO.puts("Failed to find coordinates: #{reason}")
        {:error, reason}
    end
  end

  @doc """
  Example: Find address from coordinates
  """
  def example_reverse_geocode do
    coordinates = %{lat: 40.4168, lon: -3.7038}
    
    case OpenStreetMap.find_address(coordinates) do
      {:ok, address} ->
        IO.puts("Location: #{address}")
        {:ok, address}
      
      {:error, reason} ->
        IO.puts("Failed to find address: #{reason}")
        {:error, reason}
    end
  end

  @doc """
  Example: Batch geocode multiple addresses
  """
  def example_batch_geocode do
    addresses = [
      "Madrid, Spain", 
      "Barcelona, Spain", 
      "Valencia, Spain"
    ]
    
    results = OpenStreetMap.batch_geocode(addresses)
    
    Enum.each(results, fn {address, result} ->
      case result do
        {:ok, %{lat: lat, lon: lon}} ->
          IO.puts("#{address}: #{lat}, #{lon}")
        {:error, reason} ->
          IO.puts("#{address}: Error - #{reason}")
      end
    end)
    
    results
  end

  @doc """
  Example: Search for places nearby
  """
  def example_search_nearby do
    madrid_coords = %{lat: 40.4168, lon: -3.7038}
    
    case OpenStreetMap.search_nearby(madrid_coords, "museum", 5) do
      {:ok, results} ->
        IO.puts("Found #{length(results)} museums within 5km of Madrid:")
        
        Enum.each(results, fn result ->
          IO.puts("  #{result.display_name} (#{Float.round(result.distance_km, 2)}km)")
        end)
        
        {:ok, results}
      
      {:error, reason} ->
        IO.puts("Search failed: #{reason}")
        {:error, reason}
    end
  end

  @doc """
  Example: Validate coordinates
  """
  def example_coordinate_validation do
    test_coordinates = [
      %{lat: 40.4168, lon: -3.7038},  # Valid: Madrid
      %{lat: 91, lon: 0},             # Invalid: lat > 90
      %{lat: 0, lon: 181},            # Invalid: lon > 180
      %{lat: -45.123, lon: 170.456}   # Valid: somewhere in New Zealand
    ]
    
    Enum.each(test_coordinates, fn coords ->
      validity = if OpenStreetMap.valid_coordinates?(coords), do: "Valid", else: "Invalid"
      IO.puts("#{inspect(coords)}: #{validity}")
    end)
    
    test_coordinates
  end

  @doc """
  Example: Using a custom service with mock client for testing
  """
  def example_with_custom_service do
    mock_service = OpenStreetMap.new_service(DinosaurBackend.OpenStreetMapMock)
    
    case DinosaurBackend.OpenStreetMap.Service.find_coordinates(mock_service, "Madrid") do
      {:ok, coords} ->
        IO.puts("Mock service returned: #{inspect(coords)}")
        {:ok, coords}
      
      {:error, reason} ->
        IO.puts("Mock service error: #{reason}")
        {:error, reason}
    end
  end
end