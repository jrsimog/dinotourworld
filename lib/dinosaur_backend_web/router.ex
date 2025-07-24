defmodule DinosaurBackendWeb.Router do
  use DinosaurBackendWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DinosaurBackendWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_authenticated do
    plug :accepts, ["json"]
    plug DinosaurBackendWeb.Plugs.BearerAuth
  end

  scope "/", DinosaurBackendWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Authenticated API routes
  scope "/api", DinosaurBackendWeb.Api do
    pipe_through :api_authenticated

    get "/dinosaurs", DinosaurController, :index
  end

  scope "/api" do
    pipe_through :api_authenticated

    forward "/graphql", Absinthe.Plug,
      schema: DinosaurBackendWeb.Schema
  end

  # Development-only routes (no authentication required)
  if Mix.env() == :dev do
    scope "/api" do
      pipe_through :api

      forward "/graphiql", Absinthe.Plug.GraphiQL,
        schema: DinosaurBackendWeb.Schema,
        interface: :simple
    end
  end

  # OpenAPI Documentation routes
  scope "/api" do
    pipe_through :api
    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
  end

  scope "/api" do
    pipe_through :browser
    get "/doc", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:dinosaur_backend, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DinosaurBackendWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
