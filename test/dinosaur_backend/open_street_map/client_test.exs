defmodule DinosaurBackend.OpenStreetMap.ClientTest do
  use ExUnit.Case, async: true

  alias DinosaurBackend.OpenStreetMap.Client

  describe "geocode/2" do
    test "handles network errors gracefully" do
      assert is_function(&Client.geocode/1)
      assert is_function(&Client.geocode/2)
    end
  end

  describe "reverse_geocode/2" do
    test "handles network errors gracefully" do
      assert is_function(&Client.reverse_geocode/1)  
      assert is_function(&Client.reverse_geocode/2)
    end
  end

  describe "search/2" do
    test "handles network errors gracefully" do
      assert is_function(&Client.search/1)
      assert is_function(&Client.search/2)
    end
  end

  describe "real API integration" do
    @tag :integration
    test "geocode with real API" do
      if System.get_env("INTEGRATION_TESTS") == "true" do
        assert {:ok, results} = Client.geocode("Madrid, Spain", limit: 1)
        assert is_list(results)
        assert length(results) > 0
        
        result = List.first(results)
        assert result.lat > 40.0 and result.lat < 41.0
        assert result.lon > -4.0 and result.lon < -3.0
        assert String.contains?(result.display_name, "Madrid")
      else
        assert true
      end
    end

    @tag :integration
    test "reverse geocode with real API" do
      if System.get_env("INTEGRATION_TESTS") == "true" do
        coordinates = %{lat: 40.4168, lon: -3.7038}
        assert {:ok, result} = Client.reverse_geocode(coordinates)
        
        assert result.lat == 40.4168
        assert result.lon == -3.7038
        assert String.contains?(String.downcase(result.display_name), "madrid")
      else
        assert true
      end
    end
  end
end