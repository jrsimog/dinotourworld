defmodule DinosaurBackendWeb.Schemas do
  @moduledoc """
  Esquemas OpenAPI para la documentación de la API
  """
  
  alias OpenApiSpex.{Schema}

  defmodule Dinosaur do
    @moduledoc "Schema for a Dinosaur"
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Dinosaur",
      description: "Un dinosaurio con toda su información",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "ID único del dinosaurio"},
        name: %Schema{type: :string, description: "Nombre del dinosaurio", example: "Tyrannosaurus Rex"},
        description: %Schema{type: :string, description: "Descripción del dinosaurio", example: "Gran dinosaurio carnívoro"},
        species: %Schema{type: :string, description: "Especie del dinosaurio", example: "T. rex"},
        era: %Schema{type: :string, description: "Era geológica", example: "Cretácico"},
        latitude: %Schema{type: :number, format: :float, description: "Latitud donde fue encontrado", example: 45.0},
        longitude: %Schema{type: :number, format: :float, description: "Longitud donde fue encontrado", example: -110.0}
      },
      required: [:id, :name, :description, :species, :era, :latitude, :longitude],
      example: %{
        "id" => 1,
        "name" => "Tyrannosaurus Rex",
        "description" => "Gran dinosaurio carnívoro del período Cretácico",
        "species" => "T. rex",
        "era" => "Cretácico",
        "latitude" => 45.0,
        "longitude" => -110.0
      }
    })
  end

  defmodule DinosaurResponse do
    @moduledoc "Schema for single dinosaur response"
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "DinosaurResponse",
      description: "Respuesta con un solo dinosaurio",
      type: :object,
      properties: %{
        data: Dinosaur
      },
      required: [:data]
    })
  end

  defmodule DinosaursResponse do
    @moduledoc "Schema for multiple dinosaurs response"
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "DinosaursResponse",
      description: "Respuesta exitosa con lista de dinosaurios encontrados",
      type: :object,
      properties: %{
        data: %Schema{
          type: :array,
          items: Dinosaur,
          description: "Lista de dinosaurios que cumplen con los criterios de búsqueda"
        },
        meta: %Schema{
          type: :object,
          description: "Metadatos sobre la respuesta",
          properties: %{
            total: %Schema{type: :integer, description: "Número total de dinosaurios encontrados"},
            filters: %Schema{
              type: :object,
              description: "Filtros aplicados en la búsqueda",
              properties: %{
                name: %Schema{type: :string, description: "Filtro por nombre aplicado", nullable: true},
                city: %Schema{type: :string, description: "Filtro por ciudad aplicado", nullable: true}
              }
            }
          },
          required: [:total]
        }
      },
      required: [:data, :meta],
      examples: %{
        "dinosaurs_found" => %{
          summary: "Dinosaurios encontrados con filtros",
          description: "Ejemplo de respuesta cuando se encuentran dinosaurios",
          value: %{
            "data" => [
              %{
                "id" => 1,
                "name" => "Tyrannosaurus Rex",
                "description" => "Gran dinosaurio carnívoro del período Cretácico tardío",
                "species" => "T. rex",
                "era" => "Cretácico",
                "latitude" => 47.0,
                "longitude" => -106.0
              },
              %{
                "id" => 3,
                "name" => "Tyrannosaurus Bataar",
                "description" => "Pariente asiático del T. rex",
                "species" => "T. bataar",
                "era" => "Cretácico",
                "latitude" => 43.5,
                "longitude" => 103.2
              }
            ],
            "meta" => %{
              "total" => 2,
              "filters" => %{
                "name" => "rex",
                "city" => nil
              }
            }
          }
        },
        "empty_results" => %{
          summary: "Sin resultados",
          description: "Ejemplo cuando no se encuentran dinosaurios",
          value: %{
            "data" => [],
            "meta" => %{
              "total" => 0,
              "filters" => %{
                "name" => "nonexistent",
                "city" => nil
              }
            }
          }
        }
      }
    })
  end

  defmodule ValidationErrorResponse do
    @moduledoc "Schema for validation error response (400)"
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "ValidationErrorResponse",
      description: "Respuesta cuando los parámetros de entrada son inválidos",
      type: :object,
      properties: %{
        error: %Schema{
          type: :object,
          properties: %{
            code: %Schema{type: :string, description: "Código del error", example: "VALIDATION_ERROR"},
            message: %Schema{type: :string, description: "Mensaje principal del error"},
            details: %Schema{
              type: :array,
              description: "Lista detallada de errores de validación",
              items: %Schema{
                type: :object,
                properties: %{
                  field: %Schema{type: :string, description: "Campo que causó el error"},
                  reason: %Schema{type: :string, description: "Razón del error"},
                  value: %Schema{type: :string, description: "Valor que causó el error", nullable: true}
                },
                required: [:field, :reason]
              }
            }
          },
          required: [:code, :message, :details]
        }
      },
      required: [:error],
      examples: %{
        "invalid_parameters" => %{
          summary: "Parámetros inválidos",
          description: "Ejemplo cuando los parámetros de consulta son inválidos",
          value: %{
            "error" => %{
              "code" => "VALIDATION_ERROR",
              "message" => "Los parámetros proporcionados no son válidos",
              "details" => [
                %{
                  "field" => "name",
                  "reason" => "debe tener al menos 2 caracteres",
                  "value" => "a"
                }
              ]
            }
          }
        }
      }
    })
  end

  defmodule ServerErrorResponse do
    @moduledoc "Schema for server error response (500)"
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "ServerErrorResponse", 
      description: "Respuesta cuando ocurre un error interno del servidor",
      type: :object,
      properties: %{
        error: %Schema{
          type: :object,
          properties: %{
            code: %Schema{type: :string, description: "Código del error", example: "INTERNAL_SERVER_ERROR"},
            message: %Schema{type: :string, description: "Mensaje del error"},
            timestamp: %Schema{type: :string, format: :"date-time", description: "Timestamp cuando ocurrió el error"},
            request_id: %Schema{type: :string, description: "ID único de la petición para rastreo"}
          },
          required: [:code, :message, :timestamp]
        }
      },
      required: [:error],
      examples: %{
        "database_error" => %{
          summary: "Error de base de datos",
          description: "Ejemplo cuando hay un problema con la base de datos",
          value: %{
            "error" => %{
              "code" => "DATABASE_ERROR",
              "message" => "Error al conectar con la base de datos",
              "timestamp" => "2024-01-15T10:30:00Z",
              "request_id" => "req_abc123"
            }
          }
        },
        "generic_server_error" => %{
          summary: "Error genérico del servidor",
          description: "Ejemplo de error interno no específico",
          value: %{
            "error" => %{
              "code" => "INTERNAL_SERVER_ERROR",
              "message" => "Ha ocurrido un error interno. Por favor intente más tarde.",
              "timestamp" => "2024-01-15T10:30:00Z",
              "request_id" => "req_xyz789"
            }
          }
        }
      }
    })
  end
end