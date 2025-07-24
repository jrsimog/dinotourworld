defmodule DinosaurBackendWeb.Api.DinosaurController do
  use DinosaurBackendWeb, :controller
  use OpenApiSpex.ControllerSpecs

  import Ecto.Query
  alias DinosaurBackend.Repo
  alias DinosaurBackend.Dinosaurs.Dinosaur
  alias DinosaurBackend.Findings.Finding
  alias DinosaurBackend.Locations.Location
  alias DinosaurBackendWeb.Schemas

  tags ["Dinosaurios"]

  operation :index,
    summary: "Listar dinosaurios",
    description: "Obtiene una lista de dinosaurios con filtros opcionales por nombre y ciudad donde fueron encontrados",
    parameters: [
      name: [
        in: :query,
        description: "Filtrar por nombre del dinosaurio (búsqueda parcial, case-insensitive)",
        type: :string,
        example: "rex",
        required: false
      ],
      city: [
        in: :query,
        description: "Filtrar por ciudad donde fue encontrado el dinosaurio (búsqueda parcial, case-insensitive)", 
        type: :string,
        example: "gobi",
        required: false
      ]
    ],
    responses: [
      ok: {"Lista de dinosaurios encontrados", "application/json", Schemas.DinosaursResponse},
      bad_request: {"Parámetros inválidos", "application/json", Schemas.ValidationErrorResponse},
      internal_server_error: {"Error interno del servidor", "application/json", Schemas.ServerErrorResponse}
    ]

  def index(conn, params) do
    case validate_params(params) do
      {:ok, validated_params} ->
        dinosaurs = search_dinosaurs(validated_params)
        rendered_dinosaurs = render_dinosaurs(dinosaurs)
        
        response = %{
          data: rendered_dinosaurs,
          meta: %{
            total: length(rendered_dinosaurs),
            filters: %{
              name: validated_params["name"],
              city: validated_params["city"]
            }
          }
        }
        
        json(conn, response)
        
      {:error, validation_errors} ->
        conn
        |> put_status(400)
        |> json(%{
          error: %{
            code: "VALIDATION_ERROR",
            message: "Los parámetros proporcionados no son válidos",
            details: validation_errors
          }
        })
    end
  rescue
    _error ->
      request_id = get_req_header(conn, "x-request-id") |> List.first() || generate_request_id()
      
      conn
      |> put_status(500)
      |> json(%{
        error: %{
          code: "INTERNAL_SERVER_ERROR",
          message: "Ha ocurrido un error interno. Por favor intente más tarde.",
          timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
          request_id: request_id
        }
      })
  end

  defp search_dinosaurs(params) do
    base_query = 
      from d in Dinosaur,
        left_join: f in Finding, on: f.dinosaur_id == d.id,
        left_join: l in Location, on: l.id == f.location_id,
        distinct: d.id

    query = apply_filters(base_query, params)
    
    Repo.all(query)
  end

  defp apply_filters(query, params) do
    query
    |> filter_by_name(params["name"])
    |> filter_by_city(params["city"])
  end

  defp filter_by_name(query, nil), do: query
  defp filter_by_name(query, name) when is_binary(name) do
    from [d, f, l] in query,
      where: ilike(d.name, ^"%#{name}%")
  end

  defp filter_by_city(query, nil), do: query
  defp filter_by_city(query, city) when is_binary(city) do
    from [d, f, l] in query,
      where: ilike(l.city, ^"%#{city}%")
  end

  defp render_dinosaurs(dinosaurs) do
    Enum.map(dinosaurs, fn dinosaur ->
      %{
        id: dinosaur.id,
        name: dinosaur.name,
        description: dinosaur.description,
        species: dinosaur.species,
        era: dinosaur.era,
        latitude: dinosaur.latitude,
        longitude: dinosaur.longitude
      }
    end)
  end

  defp validate_params(params) do
    errors = []

    errors = case params["name"] do
      nil -> errors
      "" -> errors
      name when is_binary(name) and byte_size(name) < 2 ->
        [%{field: "name", reason: "debe tener al menos 2 caracteres", value: name} | errors]
      name when is_binary(name) -> errors
      invalid_name ->
        [%{field: "name", reason: "debe ser una cadena de texto válida", value: to_string(invalid_name)} | errors]
    end

    errors = case params["city"] do
      nil -> errors
      "" -> errors
      city when is_binary(city) and byte_size(city) < 2 ->
        [%{field: "city", reason: "debe tener al menos 2 caracteres", value: city} | errors]
      city when is_binary(city) -> errors
      invalid_city ->
        [%{field: "city", reason: "debe ser una cadena de texto válida", value: to_string(invalid_city)} | errors]
    end

    case errors do
      [] -> {:ok, params}
      validation_errors -> {:error, Enum.reverse(validation_errors)}
    end
  end

  defp generate_request_id do
    :crypto.strong_rand_bytes(16)
    |> Base.encode16(case: :lower)
    |> binary_part(0, 16)
    |> (fn id -> "req_" <> id end).()
  end
end