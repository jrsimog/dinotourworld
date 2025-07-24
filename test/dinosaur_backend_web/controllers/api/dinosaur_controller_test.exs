defmodule DinosaurBackendWeb.Api.DinosaurControllerTest do
  use DinosaurBackendWeb.ConnCase

  alias DinosaurBackend.Dinosaurs.Dinosaur
  alias DinosaurBackend.Locations.Location
  alias DinosaurBackend.Findings.Finding

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all dinosaurs", %{conn: conn} do
      dinosaur = insert_dinosaur(%{name: "Tyrannosaurus Rex"})
      
      conn = get(conn, ~p"/api/dinosaurs")
      
      assert json_response(conn, 200)["data"] == [
        %{
          "id" => dinosaur.id,
          "name" => "Tyrannosaurus Rex",
          "description" => dinosaur.description,
          "species" => dinosaur.species,
          "era" => dinosaur.era,
          "latitude" => dinosaur.latitude,
          "longitude" => dinosaur.longitude
        }
      ]
    end

    test "returns empty list when no dinosaurs exist", %{conn: conn} do
      conn = get(conn, ~p"/api/dinosaurs")
      assert json_response(conn, 200)["data"] == []
    end

    test "filters dinosaurs by name", %{conn: conn} do
      rex = insert_dinosaur(%{name: "Tyrannosaurus Rex"})
      _raptor = insert_dinosaur(%{name: "Velociraptor"})
      
      conn = get(conn, ~p"/api/dinosaurs?name=rex")
      
      response = json_response(conn, 200)
      assert length(response["data"]) == 1
      assert hd(response["data"])["name"] == "Tyrannosaurus Rex"
      assert hd(response["data"])["id"] == rex.id
    end

    test "filters dinosaurs by city", %{conn: conn} do
      dinosaur = insert_dinosaur(%{name: "Test Dinosaur"})
      location = insert_location(%{city: "Gobi Desert", country: "Mongolia"})
      _finding = insert_finding(dinosaur, location)
      
      # Insert another dinosaur without findings in Gobi
      _other_dinosaur = insert_dinosaur(%{name: "Other Dinosaur"})
      
      conn = get(conn, ~p"/api/dinosaurs?city=gobi")
      
      response = json_response(conn, 200)
      assert length(response["data"]) == 1
      assert hd(response["data"])["name"] == "Test Dinosaur"
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
      
      # Dinosaur that matches city but not name
      raptor_gobi = insert_dinosaur(%{name: "Velociraptor"})
      _finding3 = insert_finding(raptor_gobi, gobi_location)
      
      conn = get(conn, ~p"/api/dinosaurs?name=rex&city=gobi")
      
      response = json_response(conn, 200)
      assert length(response["data"]) == 1
      assert hd(response["data"])["name"] == "Tyrannosaurus Rex"
    end

    test "case insensitive search for name", %{conn: conn} do
      _dinosaur = insert_dinosaur(%{name: "Tyrannosaurus Rex"})
      
      conn = get(conn, ~p"/api/dinosaurs?name=TYRANNOSAURUS")
      
      response = json_response(conn, 200)
      assert length(response["data"]) == 1
      assert hd(response["data"])["name"] == "Tyrannosaurus Rex"
    end

    test "case insensitive search for city", %{conn: conn} do
      dinosaur = insert_dinosaur(%{name: "Test Dinosaur"})
      location = insert_location(%{city: "Gobi Desert", country: "Mongolia"})
      _finding = insert_finding(dinosaur, location)
      
      conn = get(conn, ~p"/api/dinosaurs?city=GOBI")
      
      response = json_response(conn, 200)
      assert length(response["data"]) == 1
    end

    test "partial name matching", %{conn: conn} do
      _dinosaur = insert_dinosaur(%{name: "Tyrannosaurus Rex"})
      
      conn = get(conn, ~p"/api/dinosaurs?name=tyran")
      
      response = json_response(conn, 200)
      assert length(response["data"]) == 1
      assert hd(response["data"])["name"] == "Tyrannosaurus Rex"
    end

    test "returns empty list when no matches found", %{conn: conn} do
      _dinosaur = insert_dinosaur(%{name: "Tyrannosaurus Rex"})
      
      conn = get(conn, ~p"/api/dinosaurs?name=nonexistent")
      
      response = json_response(conn, 200)
      assert response["data"] == []
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