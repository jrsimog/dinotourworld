defmodule DinosaurBackendWeb.SchemaTest do
  use DinosaurBackendWeb.ConnCase

  alias DinosaurBackend.Dinosaurs.Dinosaur
  alias DinosaurBackend.Locations.Location
  alias DinosaurBackend.Findings.Finding

  @dinosaurs_query """
  query getDinosaurs($name: String, $city: String) {
    dinosaurs(name: $name, city: $city) {
      id
      name
      description
      species
      era
      latitude
      longitude
    }
  }
  """

  @dinosaur_query """
  query getDinosaur($id: ID!) {
    dinosaur(id: $id) {
      id
      name
      description
      species
      era
      latitude
      longitude
    }
  }
  """

  @dinosaurs_with_locations_query """
  query getDinosaursWithLocations {
    dinosaurs {
      id
      name
      locations {
        id
        city
        country
      }
    }
  }
  """

  describe "dinosaurs query" do
    test "returns all dinosaurs when no filters provided", %{conn: conn} do
      dinosaur1 = insert_dinosaur(%{name: "Tyrannosaurus Rex"})
      dinosaur2 = insert_dinosaur(%{name: "Velociraptor"})

      conn = post(conn, "/api/graphql", %{query: @dinosaurs_query})

      assert %{
        "data" => %{
          "dinosaurs" => dinosaurs
        }
      } = json_response(conn, 200)

      assert length(dinosaurs) == 2
      dinosaur_names = Enum.map(dinosaurs, & &1["name"])
      assert "Tyrannosaurus Rex" in dinosaur_names
      assert "Velociraptor" in dinosaur_names
    end

    test "returns empty list when no dinosaurs exist", %{conn: conn} do
      conn = post(conn, "/api/graphql", %{query: @dinosaurs_query})

      assert %{
        "data" => %{
          "dinosaurs" => []
        }
      } = json_response(conn, 200)
    end

    test "filters dinosaurs by name", %{conn: conn} do
      rex = insert_dinosaur(%{name: "Tyrannosaurus Rex"})
      _raptor = insert_dinosaur(%{name: "Velociraptor"})

      conn = post(conn, "/api/graphql", %{
        query: @dinosaurs_query,
        variables: %{name: "rex"}
      })

      assert %{
        "data" => %{
          "dinosaurs" => [dinosaur]
        }
      } = json_response(conn, 200)

      assert dinosaur["id"] == to_string(rex.id)
      assert dinosaur["name"] == "Tyrannosaurus Rex"
    end

    test "filters dinosaurs by city", %{conn: conn} do
      dinosaur = insert_dinosaur(%{name: "Test Dinosaur"})
      location = insert_location(%{city: "Gobi Desert", country: "Mongolia"})
      _finding = insert_finding(dinosaur, location)
      
      # Insert another dinosaur without findings in Gobi
      _other_dinosaur = insert_dinosaur(%{name: "Other Dinosaur"})

      conn = post(conn, "/api/graphql", %{
        query: @dinosaurs_query,
        variables: %{city: "gobi"}
      })

      assert %{
        "data" => %{
          "dinosaurs" => [found_dinosaur]
        }
      } = json_response(conn, 200)

      assert found_dinosaur["id"] == to_string(dinosaur.id)
      assert found_dinosaur["name"] == "Test Dinosaur"
    end

    test "filters dinosaurs by name and city combined", %{conn: conn} do
      # Dinosaur that matches both name and city
      rex_gobi = insert_dinosaur(%{name: "Tyrannosaurus Rex"})
      gobi_location = insert_location(%{city: "Gobi Desert", country: "Mongolia"})
      _finding1 = insert_finding(rex_gobi, gobi_location)
      
      # Dinosaur that matches name but not city
      rex_patagonia = insert_dinosaur(%{name: "Tyrannosaurus Rex Minor"})
      patagonia_location = insert_location(%{city: "Patagonia", country: "Argentina"})
      _finding2 = insert_finding(rex_patagonia, patagonia_location)

      conn = post(conn, "/api/graphql", %{
        query: @dinosaurs_query,
        variables: %{name: "rex", city: "gobi"}
      })

      assert %{
        "data" => %{
          "dinosaurs" => [found_dinosaur]
        }
      } = json_response(conn, 200)

      assert found_dinosaur["id"] == to_string(rex_gobi.id)
      assert found_dinosaur["name"] == "Tyrannosaurus Rex"
    end

    test "returns dinosaurs with complete data structure", %{conn: conn} do
      dinosaur = insert_dinosaur(%{
        name: "Tyrannosaurus Rex",
        description: "Large carnivorous dinosaur",
        species: "T. rex",
        era: "Cretaceous",
        latitude: 45.0,
        longitude: -110.0
      })

      conn = post(conn, "/api/graphql", %{query: @dinosaurs_query})

      assert %{
        "data" => %{
          "dinosaurs" => [found_dinosaur]
        }
      } = json_response(conn, 200)

      assert found_dinosaur["id"] == to_string(dinosaur.id)
      assert found_dinosaur["name"] == "Tyrannosaurus Rex"
      assert found_dinosaur["description"] == "Large carnivorous dinosaur"
      assert found_dinosaur["species"] == "T. rex"
      assert found_dinosaur["era"] == "Cretaceous"
      assert found_dinosaur["latitude"] == 45.0
      assert found_dinosaur["longitude"] == -110.0
    end
  end

  describe "dinosaur query" do
    test "returns dinosaur when found", %{conn: conn} do
      dinosaur = insert_dinosaur(%{name: "Tyrannosaurus Rex"})

      conn = post(conn, "/api/graphql", %{
        query: @dinosaur_query,
        variables: %{id: dinosaur.id}
      })

      assert %{
        "data" => %{
          "dinosaur" => found_dinosaur
        }
      } = json_response(conn, 200)

      assert found_dinosaur["id"] == to_string(dinosaur.id)
      assert found_dinosaur["name"] == "Tyrannosaurus Rex"
    end

    test "returns error when dinosaur not found", %{conn: conn} do
      conn = post(conn, "/api/graphql", %{
        query: @dinosaur_query,
        variables: %{id: 999}
      })

      assert %{
        "data" => %{"dinosaur" => nil},
        "errors" => [%{"message" => "Dinosaur not found"}]
      } = json_response(conn, 200)
    end
  end

  describe "dinosaurs with locations query" do
    test "returns dinosaurs with their locations", %{conn: conn} do
      dinosaur = insert_dinosaur(%{name: "Tyrannosaurus Rex"})
      location1 = insert_location(%{city: "Gobi Desert", country: "Mongolia"})
      location2 = insert_location(%{city: "Hell Creek", country: "USA"})
      
      _finding1 = insert_finding(dinosaur, location1)
      _finding2 = insert_finding(dinosaur, location2)

      conn = post(conn, "/api/graphql", %{query: @dinosaurs_with_locations_query})

      assert %{
        "data" => %{
          "dinosaurs" => [found_dinosaur]
        }
      } = json_response(conn, 200)

      assert found_dinosaur["id"] == to_string(dinosaur.id)
      assert found_dinosaur["name"] == "Tyrannosaurus Rex"
      
      locations = found_dinosaur["locations"]
      assert length(locations) == 2
      
      location_cities = Enum.map(locations, & &1["city"])
      assert "Gobi Desert" in location_cities
      assert "Hell Creek" in location_cities
    end

    test "returns dinosaur with empty locations when no findings exist", %{conn: conn} do
      dinosaur = insert_dinosaur(%{name: "Tyrannosaurus Rex"})

      conn = post(conn, "/api/graphql", %{query: @dinosaurs_with_locations_query})

      assert %{
        "data" => %{
          "dinosaurs" => [found_dinosaur]
        }
      } = json_response(conn, 200)

      assert found_dinosaur["id"] == to_string(dinosaur.id)
      assert found_dinosaur["locations"] == []
    end
  end

  describe "GraphQL errors" do
    test "returns error for invalid query syntax", %{conn: conn} do
      invalid_query = """
      query {
        dinosaurs {
          invalid_field
        }
      """

      conn = post(conn, "/api/graphql", %{query: invalid_query})

      assert %{
        "errors" => [%{"message" => message}]
      } = json_response(conn, 200)

      assert message =~ "Cannot query field" or message =~ "syntax error"
    end

    test "returns error for missing required arguments", %{conn: conn} do
      query_without_id = """
      query {
        dinosaur {
          id
          name
        }
      }
      """

      conn = post(conn, "/api/graphql", %{query: query_without_id})

      assert %{
        "errors" => [%{"message" => message}]
      } = json_response(conn, 200)

      assert message =~ "required" or message =~ "Expected type"
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