defmodule DinosaurBackendWeb.Plugs.BearerAuth do
  @moduledoc """
  Plug para autenticación con Bearer token.
  
  Verifica que el request contenga un token válido en el header Authorization.
  Si el token es inválido o falta, retorna un error 401.
  """
  
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    token = 
      case get_req_header(conn, "authorization") do
        ["Bearer " <> token] -> token
        _ -> nil
      end

    case token do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> put_resp_content_type("application/json")
        |> json(%{
          error: %{
            code: "UNAUTHORIZED",
            message: "Token de autorización requerido",
            timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
            request_id: get_request_id(conn)
          }
        })
        |> halt()

      token ->
        case validate_token(token) do
          {:ok, _} ->
            conn
            |> assign(:current_token, token)
            |> assign(:authenticated, true)

          {:error, _reason} ->
            conn
            |> put_status(:unauthorized)
            |> put_resp_content_type("application/json")
            |> json(%{
              error: %{
                code: "UNAUTHORIZED",
                message: "Token de autorización inválido",
                timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
                request_id: get_request_id(conn)
              }
            })
            |> halt()
        end
    end
  end

  defp validate_token(token) do
    valid_tokens = Application.get_env(:dinosaur_backend, :api_tokens, [])
    if token in valid_tokens, do: {:ok, token}, else: {:error, :invalid_token}
  end

  defp get_request_id(conn) do
    case get_req_header(conn, "x-request-id") do
      [request_id] -> request_id
      [] -> generate_request_id()
      _ -> generate_request_id()
    end
  end

  defp generate_request_id do
    :crypto.strong_rand_bytes(16)
    |> Base.encode16(case: :lower)
    |> binary_part(0, 16)
    |> (fn id -> "req_" <> id end).()
  end
end