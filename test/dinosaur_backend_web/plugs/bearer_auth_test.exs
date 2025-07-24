defmodule DinosaurBackendWeb.Plugs.BearerAuthTest do
  use DinosaurBackendWeb.ConnCase
  alias DinosaurBackendWeb.Plugs.BearerAuth

  describe "Bearer token authentication" do
    test "allows requests with valid dev token", %{conn: conn} do
      conn = 
        conn
        |> put_req_header("authorization", "Bearer dev_token_12345")
        |> BearerAuth.call(BearerAuth.init([]))

      refute conn.halted
      assert conn.assigns[:authenticated] == true
      assert conn.assigns[:current_token] == "dev_token_12345"
    end

    test "allows requests with valid test token", %{conn: conn} do
      conn = 
        conn
        |> put_req_header("authorization", "Bearer test_token_67890")
        |> BearerAuth.call(BearerAuth.init([]))

      refute conn.halted
      assert conn.assigns[:authenticated] == true
      assert conn.assigns[:current_token] == "test_token_67890"
    end

    test "rejects requests without authorization header", %{conn: conn} do
      conn = BearerAuth.call(conn, BearerAuth.init([]))

      assert conn.halted
      assert conn.status == 401
      assert %{"error" => error} = json_response(conn, 401)
      assert error["code"] == "UNAUTHORIZED"
      assert error["message"] == "Token de autorización requerido"
      assert Map.has_key?(error, "timestamp")
      assert Map.has_key?(error, "request_id")
    end

    test "rejects requests with invalid token format", %{conn: conn} do
      conn = 
        conn
        |> put_req_header("authorization", "InvalidFormat token123")
        |> BearerAuth.call(BearerAuth.init([]))

      assert conn.halted
      assert conn.status == 401
      assert %{"error" => error} = json_response(conn, 401)
      assert error["code"] == "UNAUTHORIZED"
      assert error["message"] == "Token de autorización requerido"
      assert Map.has_key?(error, "timestamp")
      assert Map.has_key?(error, "request_id")
    end

    test "rejects requests with invalid token", %{conn: conn} do
      conn = 
        conn
        |> put_req_header("authorization", "Bearer invalid_token")
        |> BearerAuth.call(BearerAuth.init([]))

      assert conn.halted
      assert conn.status == 401
      assert %{"error" => error} = json_response(conn, 401)
      assert error["code"] == "UNAUTHORIZED"
      assert error["message"] == "Token de autorización inválido"
      assert Map.has_key?(error, "timestamp")
      assert Map.has_key?(error, "request_id")
    end

    test "rejects requests with empty token", %{conn: conn} do
      conn = 
        conn
        |> put_req_header("authorization", "Bearer ")
        |> BearerAuth.call(BearerAuth.init([]))

      assert conn.halted
      assert conn.status == 401
      assert %{"error" => error} = json_response(conn, 401)
      assert error["code"] == "UNAUTHORIZED"
      assert error["message"] == "Token de autorización inválido"
      assert Map.has_key?(error, "timestamp")
      assert Map.has_key?(error, "request_id")
    end

    test "rejects requests with only 'Bearer' keyword", %{conn: conn} do
      conn = 
        conn
        |> put_req_header("authorization", "Bearer")
        |> BearerAuth.call(BearerAuth.init([]))

      assert conn.halted
      assert conn.status == 401
      assert %{"error" => error} = json_response(conn, 401)
      assert error["code"] == "UNAUTHORIZED"
      assert error["message"] == "Token de autorización requerido"
      assert Map.has_key?(error, "timestamp")
      assert Map.has_key?(error, "request_id")
    end

    test "request_id is generated when x-request-id header is missing", %{conn: conn} do
      conn = BearerAuth.call(conn, BearerAuth.init([]))

      assert conn.halted
      assert conn.status == 401
      assert %{"error" => error} = json_response(conn, 401)
      assert String.starts_with?(error["request_id"], "req_")
      assert String.length(error["request_id"]) == 20  # "req_" + 16 chars
    end

    test "uses provided x-request-id header when available", %{conn: conn} do
      custom_request_id = "custom_request_123"
      
      conn = 
        conn
        |> put_req_header("x-request-id", custom_request_id)
        |> BearerAuth.call(BearerAuth.init([]))

      assert conn.halted
      assert conn.status == 401
      assert %{"error" => error} = json_response(conn, 401)
      assert error["request_id"] == custom_request_id
    end
  end
end