defmodule DinosaurBackend.OpenStreetMap.ServiceTest do
  use ExUnit.Case, async: true

  alias DinosaurBackend.OpenStreetMap.Service

  describe "new/1" do
    test "creates service with default client from config" do
      service = Service.new()
      assert %Service{client: DinosaurBackend.Mocks.OpenStreetMapMock} = service
    end

    test "creates service with custom client" do
      service = Service.new(DinosaurBackend.OpenStreetMap.Client)
      assert %Service{client: DinosaurBackend.OpenStreetMap.Client} = service
    end
  end

  describe "find_coordinates/2" do
    setup do
      service = Service.new()
      {:ok, service: service}
    end

    test "returns coordinates for valid address", %{service: service} do
      assert {:ok, %{lat: lat, lon: lon}} = Service.find_coordinates(service, "Madrid, Spain")
      assert is_float(lat) or is_integer(lat)
      assert is_float(lon) or is_integer(lon)
    end

    test "returns error for invalid address", %{service: service} do
      assert {:error, "Address not found"} = Service.find_coordinates(service, "invalid address")
    end

    test "handles API errors", %{service: service} do
      assert {:error, "API error"} = Service.find_coordinates(service, "error test")
    end
  end

  describe "find_address/2" do
    setup do
      service = Service.new()
      {:ok, service: service}
    end

    test "returns address for valid coordinates", %{service: service} do
      coordinates = %{lat: 40.4168, lon: -3.7038}
      assert {:ok, address} = Service.find_address(service, coordinates)
      assert is_binary(address)
      assert String.contains?(address, "Madrid")
    end

    test "handles invalid coordinates", %{service: service} do
      coordinates = %{lat: 91, lon: 181}
      assert {:error, _reason} = Service.find_address(service, coordinates)
    end
  end

  describe "batch_geocode/2" do
    setup do
      service = Service.new()
      {:ok, service: service}
    end

    test "geocodes multiple addresses", %{service: service} do
      addresses = ["Madrid, Spain", "Barcelona, Spain"]
      results = Service.batch_geocode(service, addresses)
      
      assert is_map(results)
      assert Map.has_key?(results, "Madrid, Spain")
      assert Map.has_key?(results, "Barcelona, Spain")
      
      assert {:ok, %{lat: _, lon: _}} = results["Madrid, Spain"]
      assert {:ok, %{lat: _, lon: _}} = results["Barcelona, Spain"]
    end

    test "handles mixed valid and invalid addresses", %{service: service} do
      addresses = ["Madrid, Spain", "invalid address"]
      results = Service.batch_geocode(service, addresses)
      
      assert {:ok, %{lat: _, lon: _}} = results["Madrid, Spain"]
      assert {:error, "Address not found"} = results["invalid address"]
    end
  end

  describe "search_nearby/4" do
    setup do
      service = Service.new()
      {:ok, service: service}
    end

    test "searches for places near coordinates", %{service: service} do
      coordinates = %{lat: 40.4168, lon: -3.7038}
      assert {:ok, results} = Service.search_nearby(service, coordinates, "museum", 10)
      assert is_list(results)
    end

    test "filters results by distance", %{service: service} do
      coordinates = %{lat: 40.4168, lon: -3.7038}
      assert {:ok, results} = Service.search_nearby(service, coordinates, "Madrid", 1)
      
      Enum.each(results, fn result ->
        assert Map.has_key?(result, :distance_km)
        assert result.distance_km <= 1
      end)
    end
  end

  describe "valid_coordinates?/1" do
    test "validates correct coordinates" do
      assert Service.valid_coordinates?(%{lat: 40.4168, lon: -3.7038})
      assert Service.valid_coordinates?(%{lat: 0, lon: 0})
      assert Service.valid_coordinates?(%{lat: -90, lon: -180})
      assert Service.valid_coordinates?(%{lat: 90, lon: 180})
    end

    test "rejects invalid coordinates" do
      refute Service.valid_coordinates?(%{lat: 91, lon: 0})
      refute Service.valid_coordinates?(%{lat: 0, lon: 181})
      refute Service.valid_coordinates?(%{lat: -91, lon: 0})
      refute Service.valid_coordinates?(%{lat: 0, lon: -181})
      refute Service.valid_coordinates?(%{})
      refute Service.valid_coordinates?(%{lat: "invalid", lon: 0})
    end
  end

end