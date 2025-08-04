defmodule DinosaurBackend.Mocks do
  @moduledoc """
  Centralized mocks for testing.
  
  This module contains all mock implementations used in tests,
  following Phoenix conventions for test organization.
  """

  defmodule OpenStreetMapMock do
    @moduledoc """
    Mock implementation of OpenStreetMap.Behaviour for testing.
    """

    @behaviour DinosaurBackend.OpenStreetMap.Behaviour

    @sample_geocode_result %{
      lat: 40.4168,
      lon: -3.7038,
      display_name: "Madrid, Community of Madrid, Spain",
      address: %{
        city: "Madrid",
        state: "Community of Madrid",
        country: "Spain",
        country_code: "es"
      }
    }

    @sample_barcelona_result %{
      lat: 41.3851,
      lon: 2.1734,
      display_name: "Barcelona, Catalonia, Spain",
      address: %{
        city: "Barcelona",
        state: "Catalonia",
        country: "Spain",
        country_code: "es"
      }
    }

    @impl true
    def geocode(address, _opts \\ []) do
      case String.downcase(address) do
        "madrid" <> _ -> {:ok, [@sample_geocode_result]}
        "barcelona" <> _ -> {:ok, [@sample_barcelona_result]}
        "invalid" <> _ -> {:ok, []}
        "error" <> _ -> {:error, "API error"}
        _ -> {:ok, [@sample_geocode_result]}
      end
    end

    @impl true
    def reverse_geocode(coordinates, _opts \\ []) do
      case coordinates do
        %{lat: 40.4168, lon: -3.7038} -> {:ok, @sample_geocode_result}
        %{lat: lat, lon: lon} when lat >= -90 and lat <= 90 and lon >= -180 and lon <= 180 ->
          {:ok, @sample_geocode_result}
        _ -> {:error, "Invalid coordinates"}
      end
    end

    @impl true
    def search(query, _opts \\ []) do
      geocode(query)
    end
  end
end