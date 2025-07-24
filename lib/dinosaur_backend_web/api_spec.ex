defmodule DinosaurBackendWeb.ApiSpec do
  alias OpenApiSpex.{Components, Info, OpenApi, SecurityScheme, Server}
  @behaviour OpenApiSpex.OpenApi

  @impl OpenApiSpex.OpenApi
  def spec do
    spec = %OpenApi{
      info: %Info{
        title: "Dinosaur Backend API",
        description: "API para gestión y búsqueda de dinosaurios con autenticación Bearer token",
        version: "1.0.0"
      },
      servers: [
        Server.from_endpoint(DinosaurBackendWeb.Endpoint)
      ],
      paths: paths(),
      security: [
        %{"BearerAuth" => []}
      ],
      components: %Components{
        securitySchemes: %{
          "BearerAuth" => %SecurityScheme{
            type: "http",
            scheme: "bearer",
            bearerFormat: "JWT",
            description: "Ingrese su token de API. Ejemplo: dev_token_12345"
          }
        }
      }
    }
    
    # Resolve all schemas automatically
    OpenApiSpex.resolve_schema_modules(spec)
  end

  def paths do
    OpenApiSpex.Paths.from_router(DinosaurBackendWeb.Router)
  end
end