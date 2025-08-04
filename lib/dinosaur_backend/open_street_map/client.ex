defmodule DinosaurBackend.OpenStreetMap.Client do
  @moduledoc """
  HTTP client for OpenStreetMap Nominatim API.
  
  This module implements the OpenStreetMap.Behaviour and provides
  concrete HTTP-based implementations for geocoding services.
  """

  @behaviour DinosaurBackend.OpenStreetMap.Behaviour

  require Logger

  @base_url "https://nominatim.openstreetmap.org"
  @default_format "json"
  @default_limit 5
  @user_agent "DinosaurBackend/1.0 (Elixir Phoenix Application)"

  @impl true
  def geocode(address, opts \\ []) do
    params = build_geocode_params(address, opts)
    
    case make_request("/search", params) do
      {:ok, results} when is_list(results) ->
        parsed_results = Enum.map(results, &parse_geocode_result/1)
        {:ok, parsed_results}
      
      {:ok, _} ->
        {:error, "Unexpected response format"}
      
      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def reverse_geocode(coordinates, opts \\ []) do
    params = build_reverse_geocode_params(coordinates, opts)
    
    case make_request("/reverse", params) do
      {:ok, result} when is_map(result) ->
        parsed_result = parse_geocode_result(result)
        {:ok, parsed_result}
      
      {:ok, _} ->
        {:error, "Unexpected response format"}
      
      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def search(query, opts \\ []) do
    geocode(query, opts)
  end

  defp build_geocode_params(address, opts) do
    base_params = %{
      "q" => address,
      "format" => @default_format,
      "limit" => Keyword.get(opts, :limit, @default_limit),
      "addressdetails" => "1"
    }
    
    opts
    |> Enum.reduce(base_params, fn {key, value}, acc ->
      case key do
        :viewbox -> Map.put(acc, "viewbox", value)
        :bounded -> Map.put(acc, "bounded", if(value, do: "1", else: "0"))
        :countrycodes -> Map.put(acc, "countrycodes", value)
        _ -> acc
      end
    end)
  end

  defp build_reverse_geocode_params(coordinates, opts) do
    base_params = %{
      "lat" => coordinates.lat,
      "lon" => coordinates.lon,
      "format" => @default_format,
      "addressdetails" => "1"
    }
    
    opts
    |> Enum.reduce(base_params, fn {key, value}, acc ->
      case key do
        :zoom -> Map.put(acc, "zoom", value)
        _ -> acc
      end
    end)
  end

  defp make_request(path, params) do
    url = @base_url <> path
    query_string = URI.encode_query(params)
    full_url = "#{url}?#{query_string}"
    
    headers = [
      {"User-Agent", @user_agent},
      {"Accept", "application/json"}
    ]
    
    Logger.debug("Making request to OpenStreetMap: #{full_url}")
    
    case Finch.build(:get, full_url, headers) |> Finch.request(DinosaurBackend.Finch) do
      {:ok, %{status: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} -> {:ok, data}
          {:error, _} -> {:error, "Invalid JSON response"}
        end
      
      {:ok, %{status: status, body: body}} ->
        Logger.warning("OpenStreetMap API returned status #{status}: #{body}")
        {:error, "API request failed with status #{status}"}
      
      {:error, reason} ->
        Logger.error("Failed to make request to OpenStreetMap: #{inspect(reason)}")
        {:error, "Network request failed"}
    end
  end

  defp parse_geocode_result(result) do
    %{
      lat: parse_float(result["lat"]),
      lon: parse_float(result["lon"]),
      display_name: result["display_name"] || "",
      address: parse_address(result["address"] || %{})
    }
  end

  defp parse_address(address_data) when is_map(address_data) do
    %{
      house_number: address_data["house_number"],
      road: address_data["road"],
      city: address_data["city"] || address_data["town"] || address_data["village"],
      state: address_data["state"],
      country: address_data["country"],
      country_code: address_data["country_code"],
      postcode: address_data["postcode"]
    }
  end

  defp parse_address(_), do: %{}

  defp parse_float(value) when is_binary(value) do
    case Float.parse(value) do
      {float_val, _} -> float_val
      :error -> 0.0
    end
  end

  defp parse_float(value) when is_float(value), do: value
  defp parse_float(value) when is_integer(value), do: value * 1.0
  defp parse_float(_), do: 0.0
end