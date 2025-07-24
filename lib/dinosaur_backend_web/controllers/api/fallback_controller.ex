defmodule DinosaurBackendWeb.Api.FallbackController do
  use DinosaurBackendWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: DinosaurBackendWeb.ErrorJSON)
    |> render(:"404")
  end
end
