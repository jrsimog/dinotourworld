defmodule DinosaurBackend.OpenStreetMap.NoRealApiCallsTest do
  use ExUnit.Case, async: true

  alias DinosaurBackend.OpenStreetMap

  @moduledoc """
  Tests to ensure no real API calls are made during testing.
  These tests verify that the mock is working and responses are predictable.
  """

  describe "mock verification" do
    test "geocode returns predictable mock data" do
      assert {:ok, %{lat: 40.4168, lon: -3.7038}} = OpenStreetMap.find_coordinates("Madrid")
      assert {:ok, %{lat: 41.3851, lon: 2.1734}} = OpenStreetMap.find_coordinates("Barcelona")
      assert {:ok, %{lat: 40.4168, lon: -3.7038}} = OpenStreetMap.find_coordinates("Any Other City")
    end

    test "geocode returns predictable errors for specific inputs" do
      assert {:error, "Address not found"} = OpenStreetMap.find_coordinates("invalid")
      assert {:error, "API error"} = OpenStreetMap.find_coordinates("error")
    end

    test "reverse geocode returns predictable mock data" do
      madrid_coords = %{lat: 40.4168, lon: -3.7038}
      assert {:ok, "Madrid, Community of Madrid, Spain"} = OpenStreetMap.find_address(madrid_coords)
      
      other_coords = %{lat: 25.7617, lon: -80.1918}
      assert {:ok, "Madrid, Community of Madrid, Spain"} = OpenStreetMap.find_address(other_coords)
    end

    test "reverse geocode returns predictable errors" do
      invalid_coords = %{lat: 91, lon: 181}
      assert {:error, "Invalid coordinates"} = OpenStreetMap.find_address(invalid_coords)
    end

    test "all operations complete quickly (indicating no network calls)" do
      start_time = System.monotonic_time(:millisecond)
      
      {:ok, _} = OpenStreetMap.find_coordinates("Madrid")
      {:ok, _} = OpenStreetMap.find_address(%{lat: 40.4168, lon: -3.7038})
      _results = OpenStreetMap.batch_geocode(["Madrid", "Barcelona", "Valencia"])
      {:ok, _} = OpenStreetMap.search_nearby(%{lat: 40.4168, lon: -3.7038}, "museum")
      
      end_time = System.monotonic_time(:millisecond)
      duration = end_time - start_time
      
      assert duration < 100, "Operations took #{duration}ms, suggesting real API calls"
    end

    test "configuration is correctly set to use mock in test environment" do
      config = Application.get_env(:dinosaur_backend, :openstreetmap, [])
      client = Keyword.get(config, :client)
      
      assert client == DinosaurBackend.Mocks.OpenStreetMapMock,
        "Expected mock client in test env, got: #{inspect(client)}"
    end

    test "service uses mock client from configuration" do
      service = DinosaurBackend.OpenStreetMap.Service.new()
      assert service.client == DinosaurBackend.Mocks.OpenStreetMapMock
    end
  end
end