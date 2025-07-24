defmodule DinosaurBackendWeb.Api.DinosaurControllerResponseTest do
  use DinosaurBackendWeb.ConnCase

  alias DinosaurBackend.Dinosaurs.Dinosaur
  alias DinosaurBackend.Locations.Location
  alias DinosaurBackend.Findings.Finding

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "response structure" do
    test "returns proper structure with metadata for successful response", %{conn: conn} do
      dinosaur = insert_dinosaur(%{name: "Tyrannosaurus Rex"})
      location = insert_location(%{city: "Hell Creek", country: "USA"})
      _finding = insert_finding(dinosaur, location)
      
      conn = get(conn, ~p"/api/dinosaurs?name=rex")
      
      assert %{
        "data" => [dinosaur_data],
        "meta" => %{
          "total" => 1,
          "filters" => %{
            "name" => "rex",
            "city" => nil
          }
        }
      } = json_response(conn, 200)
      
      assert %{
        "id" => _,
        "name" => "Tyrannosaurus Rex",
        "description" => _,
        "species" => _,
        "era" => _,
        "latitude" => _,
        "longitude" => _
      } = dinosaur_data
    end

    test "returns empty results with proper metadata", %{conn: conn} do
      conn = get(conn, ~p"/api/dinosaurs?name=nonexistent")
      
      assert %{
        "data" => [],
        "meta" => %{
          "total" => 0,
          "filters" => %{
            "name" => "nonexistent",
            "city" => nil
          }
        }
      } = json_response(conn, 200)
    end

    test "returns multiple dinosaurs with correct total count", %{conn: conn} do
      _dino1 = insert_dinosaur(%{name: "Tyrannosaurus Rex"})
      _dino2 = insert_dinosaur(%{name: "Tyrannosaurus Bataar"})
      _dino3 = insert_dinosaur(%{name: "Velociraptor"})
      
      conn = get(conn, ~p"/api/dinosaurs?name=tyrannosaurus")
      
      assert %{
        "data" => dinosaurs,
        "meta" => %{
          "total" => 2,
          "filters" => %{
            "name" => "tyrannosaurus",
            "city" => nil
          }
        }
      } = json_response(conn, 200)
      
      assert length(dinosaurs) == 2
    end

    test "includes both filters when provided", %{conn: conn} do
      dinosaur = insert_dinosaur(%{name: "Tyrannosaurus Rex"})
      location = insert_location(%{city: "Gobi Desert", country: "Mongolia"})
      _finding = insert_finding(dinosaur, location)
      
      conn = get(conn, ~p"/api/dinosaurs?name=rex&city=gobi")
      
      assert %{
        "meta" => %{
          "filters" => %{
            "name" => "rex",
            "city" => "gobi"
          }
        }
      } = json_response(conn, 200)
    end
  end

  describe "validation errors" do
    test "returns validation error for short name parameter", %{conn: conn} do
      conn = get(conn, ~p"/api/dinosaurs?name=a")
      
      assert %{
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
      } = json_response(conn, 400)
    end

    test "returns validation error for short city parameter", %{conn: conn} do
      conn = get(conn, ~p"/api/dinosaurs?city=x")
      
      assert %{
        "error" => %{
          "code" => "VALIDATION_ERROR",
          "message" => "Los parámetros proporcionados no son válidos",
          "details" => [
            %{
              "field" => "city",
              "reason" => "debe tener al menos 2 caracteres",
              "value" => "x"
            }
          ]
        }
      } = json_response(conn, 400)
    end

    test "returns multiple validation errors when both parameters are invalid", %{conn: conn} do
      conn = get(conn, ~p"/api/dinosaurs?name=a&city=b")
      
      assert %{
        "error" => %{
          "code" => "VALIDATION_ERROR",
          "message" => "Los parámetros proporcionados no son válidos",
          "details" => details
        }
      } = json_response(conn, 400)
      
      assert length(details) == 2
      
      name_error = Enum.find(details, &(&1["field"] == "name"))
      city_error = Enum.find(details, &(&1["field"] == "city"))
      
      assert name_error["reason"] == "debe tener al menos 2 caracteres"
      assert city_error["reason"] == "debe tener al menos 2 caracteres"
    end

    test "accepts empty parameters as valid", %{conn: conn} do
      conn = get(conn, ~p"/api/dinosaurs?name=&city=")
      
      assert %{
        "data" => _,
        "meta" => %{
          "filters" => %{
            "name" => "",
            "city" => ""
          }
        }
      } = json_response(conn, 200)
    end
  end

  # Helper functions for creating test data
  defp insert_dinosaur(attrs \\ %{}) do
    default_attrs = %{
      name: "Test Dinosaur",
      description: "A test dinosaur",
      species: "T. testus",
      era: "Test Era",
      latitude: 40.0,
      longitude: -100.0
    }

    attrs = Map.merge(default_attrs, attrs)

    %Dinosaur{}
    |> Dinosaur.changeset(attrs)
    |> DinosaurBackend.Repo.insert!()
  end

  defp insert_location(attrs \\ %{}) do
    default_attrs = %{
      city: "Test City",
      country: "Test Country",
      latitude: 40.0,
      longitude: -100.0
    }

    attrs = Map.merge(default_attrs, attrs)

    %Location{}
    |> Location.changeset(attrs)
    |> DinosaurBackend.Repo.insert!()
  end

  defp insert_finding(dinosaur, location, attrs \\ %{}) do
    default_attrs = %{
      dinosaur_id: dinosaur.id,
      location_id: location.id,
      year: 2023,
      source: "Test Source"
    }

    attrs = Map.merge(default_attrs, attrs)

    %Finding{}
    |> Finding.changeset(attrs)
    |> DinosaurBackend.Repo.insert!()
  end
end