defmodule DinosaurBackend.OpenStreetMap.IntegrationTest do
  use ExUnit.Case, async: true

  alias DinosaurBackend.OpenStreetMap

  @moduledoc """
  Integration tests that verify the mock is working correctly in test environment.
  These tests ensure no real API calls are made during testing.
  """

  describe "integration with mock" do
    test "find_coordinates uses mock automatically" do
      assert {:ok, %{lat: lat, lon: lon}} = OpenStreetMap.find_coordinates("Madrid, Spain")
      assert lat == 40.4168
      assert lon == -3.7038
    end

    test "find_address uses mock automatically" do
      coordinates = %{lat: 40.4168, lon: -3.7038}
      assert {:ok, address} = OpenStreetMap.find_address(coordinates)
      assert String.contains?(address, "Madrid")
    end

    test "batch_geocode uses mock automatically" do
      addresses = ["Madrid, Spain", "Barcelona, Spain"]
      results = OpenStreetMap.batch_geocode(addresses)
      
      assert {:ok, %{lat: 40.4168, lon: -3.7038}} = results["Madrid, Spain"]
      assert {:ok, %{lat: 41.3851, lon: 2.1734}} = results["Barcelona, Spain"]
    end

    test "search_nearby uses mock automatically" do
      madrid_coords = %{lat: 40.4168, lon: -3.7038}
      assert {:ok, results} = OpenStreetMap.search_nearby(madrid_coords, "museum", 10)
      assert is_list(results)
    end

    test "mock handles errors correctly" do
      assert {:error, "Address not found"} = OpenStreetMap.find_coordinates("invalid address")
      assert {:error, "API error"} = OpenStreetMap.find_coordinates("error test")
    end

    test "mock handles invalid coordinates" do
      invalid_coords = %{lat: 91, lon: 181}
      assert {:error, "Invalid coordinates"} = OpenStreetMap.find_address(invalid_coords)
    end
  end
end