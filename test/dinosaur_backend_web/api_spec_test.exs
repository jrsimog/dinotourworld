defmodule DinosaurBackendWeb.ApiSpecTest do
  use DinosaurBackendWeb.ConnCase

  describe "OpenAPI spec" do
    test "generates valid OpenAPI spec", %{conn: conn} do
      conn = get(conn, "/api/openapi")
      
      assert response = json_response(conn, 200)
      
      # Verify basic OpenAPI structure
      assert %{
        "openapi" => _,
        "info" => %{
          "title" => "Dinosaur Backend API",
          "version" => "1.0.0"
        },
        "paths" => paths,
        "components" => components
      } = response
      
      # Verify dinosaurs endpoint is documented
      assert Map.has_key?(paths, "/api/dinosaurs")
      
      # Verify get operation is documented
      get_operation = get_in(paths, ["/api/dinosaurs", "get"])
      assert get_operation
      assert get_operation["summary"] == "Listar dinosaurios"
      assert get_operation["tags"] == ["Dinosaurios"]
      
      # Verify parameters are documented
      parameters = get_operation["parameters"]
      assert is_list(parameters)
      assert length(parameters) == 2
      
      # Verify responses are documented
      responses = get_operation["responses"]
      assert Map.has_key?(responses, "200")
      assert Map.has_key?(responses, "400")
      assert Map.has_key?(responses, "500")
      
      # Verify components exist
      assert Map.has_key?(components, "schemas")
    end

    test "SwaggerUI is accessible at /api/doc", %{conn: conn} do
      conn = get(conn, "/api/doc")
      assert html_response(conn, 200) =~ "Swagger UI"
    end
  end
end