defmodule DinosaurBackend.OpenStreetMap.BehaviourTest do
  @moduledoc """
  Tests for OpenStreetMap.Behaviour implementations.
  
  This module defines shared tests that can be used to verify
  any implementation of the OpenStreetMap.Behaviour.
  """

  defmacro __using__(opts) do
    client_module = Keyword.fetch!(opts, :client)

    quote do
      use ExUnit.Case, async: true

      @client unquote(client_module)

      describe "geocode/2" do
        test "returns coordinates for valid address" do
          assert {:ok, results} = @client.geocode("Madrid, Spain")
          assert is_list(results)
          assert length(results) > 0
          
          result = List.first(results)
          assert is_float(result.lat) or is_integer(result.lat)
          assert is_float(result.lon) or is_integer(result.lon)
          assert is_binary(result.display_name)
          assert is_map(result.address)
        end

        test "returns empty list for invalid address" do
          assert {:ok, []} = @client.geocode("invalid address that does not exist")
        end

        test "handles API errors gracefully" do
          assert {:error, _reason} = @client.geocode("error test")
        end
      end

      describe "reverse_geocode/2" do
        test "returns address for valid coordinates" do
          coordinates = %{lat: 40.4168, lon: -3.7038}
          assert {:ok, result} = @client.reverse_geocode(coordinates)
          
          assert is_float(result.lat) or is_integer(result.lat)
          assert is_float(result.lon) or is_integer(result.lon)
          assert is_binary(result.display_name)
          assert is_map(result.address)
        end

        test "handles invalid coordinates" do
          coordinates = %{lat: 91, lon: 181}
          assert {:error, _reason} = @client.reverse_geocode(coordinates)
        end
      end

      describe "search/2" do
        test "returns search results" do
          assert {:ok, results} = @client.search("Madrid")
          assert is_list(results)
          
          if length(results) > 0 do
            result = List.first(results)
            assert is_float(result.lat) or is_integer(result.lat)
            assert is_float(result.lon) or is_integer(result.lon)
            assert is_binary(result.display_name)
          end
        end

        test "handles search errors" do
          assert {:error, _reason} = @client.search("error test")
        end
      end
    end
  end
end