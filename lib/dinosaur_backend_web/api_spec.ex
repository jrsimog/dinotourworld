defmodule DinosaurBackendWeb.ApiSpec do
  alias OpenApiSpex.{Info, OpenApi, Server}
  @behaviour OpenApiSpex.OpenApi

  @impl OpenApiSpex.OpenApi
  def spec do
    spec = %OpenApi{
      info: %Info{
        title: "Dinosaur Backend API",
        description: "API para gestión y búsqueda de dinosaurios",
        version: "1.0.0"
      },
      servers: [
        Server.from_endpoint(DinosaurBackendWeb.Endpoint)
      ],
      paths: paths()
    }
    
    # Resolve all schemas automatically
    OpenApiSpex.resolve_schema_modules(spec)
  end

  def paths do
    OpenApiSpex.Paths.from_router(DinosaurBackendWeb.Router)
  end
end