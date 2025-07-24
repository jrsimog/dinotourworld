defmodule DinosaurBackendWeb.Resolvers.DinosaurTest do
  use DinosaurBackend.DataCase

  alias DinosaurBackendWeb.Resolvers.Dinosaur
  alias DinosaurBackend.Dinosaurs.Dinosaur, as: DinosaurStruct
  alias DinosaurBackend.Locations.Location
  alias DinosaurBackend.Findings.Finding

  describe "list_dinosaurs/3" do
    test "returns all dinosaurs when no filters provided" do
      dinosaur1 = insert_dinosaur(%{name: "Tyrannosaurus Rex"})
      dinosaur2 = insert_dinosaur(%{name: "Velociraptor"})

      assert {:ok, dinosaurs} = Dinosaur.list_dinosaurs(nil, %{}, nil)
      
      assert length(dinosaurs) == 2
      dinosaur_names = Enum.map(dinosaurs, & &1.name)
      assert "Tyrannosaurus Rex" in dinosaur_names
      assert "Velociraptor" in dinosaur_names
    end

    test "returns empty list when no dinosaurs exist" do
      assert {:ok, []} = Dinosaur.list_dinosaurs(nil, %{}, nil)
    end

    test "filters dinosaurs by name" do
      rex = insert_dinosaur(%{name: "Tyrannosaurus Rex"})
      _raptor = insert_dinosaur(%{name: "Velociraptor"})

      assert {:ok, [found_dinosaur]} = Dinosaur.list_dinosaurs(nil, %{name: "rex"}, nil)
      assert found_dinosaur.id == rex.id
      assert found_dinosaur.name == "Tyrannosaurus Rex"
    end

    test "filters dinosaurs by city" do
      dinosaur = insert_dinosaur(%{name: "Test Dinosaur"})
      location = insert_location(%{city: "Gobi Desert", country: "Mongolia"})
      _finding = insert_finding(dinosaur, location)
      
      # Insert another dinosaur without findings in Gobi
      _other_dinosaur = insert_dinosaur(%{name: "Other Dinosaur"})

      assert {:ok, [found_dinosaur]} = Dinosaur.list_dinosaurs(nil, %{city: "gobi"}, nil)
      assert found_dinosaur.id == dinosaur.id
      assert found_dinosaur.name == "Test Dinosaur"
    end

    test "filters dinosaurs by name and city combined" do
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

      assert {:ok, [found_dinosaur]} = Dinosaur.list_dinosaurs(nil, %{name: "rex", city: "gobi"}, nil)
      assert found_dinosaur.id == rex_gobi.id
      assert found_dinosaur.name == "Tyrannosaurus Rex"
    end

    test "case insensitive search for name" do
      dinosaur = insert_dinosaur(%{name: "Tyrannosaurus Rex"})

      assert {:ok, [found_dinosaur]} = Dinosaur.list_dinosaurs(nil, %{name: "TYRANNOSAURUS"}, nil)
      assert found_dinosaur.id == dinosaur.id
    end

    test "case insensitive search for city" do
      dinosaur = insert_dinosaur(%{name: "Test Dinosaur"})
      location = insert_location(%{city: "Gobi Desert", country: "Mongolia"})
      _finding = insert_finding(dinosaur, location)

      assert {:ok, [found_dinosaur]} = Dinosaur.list_dinosaurs(nil, %{city: "GOBI"}, nil)
      assert found_dinosaur.id == dinosaur.id
    end

    test "partial name matching" do
      dinosaur = insert_dinosaur(%{name: "Tyrannosaurus Rex"})

      assert {:ok, [found_dinosaur]} = Dinosaur.list_dinosaurs(nil, %{name: "tyran"}, nil)
      assert found_dinosaur.id == dinosaur.id
    end

    test "returns empty list when no matches found" do
      _dinosaur = insert_dinosaur(%{name: "Tyrannosaurus Rex"})

      assert {:ok, []} = Dinosaur.list_dinosaurs(nil, %{name: "nonexistent"}, nil)
    end

    test "ignores nil filter values" do
      dinosaur = insert_dinosaur(%{name: "Test Dinosaur"})

      assert {:ok, [found_dinosaur]} = Dinosaur.list_dinosaurs(nil, %{name: nil, city: nil}, nil)
      assert found_dinosaur.id == dinosaur.id
    end
  end

  describe "get_dinosaur/3" do
    test "returns dinosaur when found" do
      dinosaur = insert_dinosaur(%{name: "Tyrannosaurus Rex"})

      assert {:ok, found_dinosaur} = Dinosaur.get_dinosaur(nil, %{id: dinosaur.id}, nil)
      assert found_dinosaur.id == dinosaur.id
      assert found_dinosaur.name == "Tyrannosaurus Rex"
    end

    test "returns error when dinosaur not found" do
      assert {:error, "Dinosaur not found"} = Dinosaur.get_dinosaur(nil, %{id: 999}, nil)
    end

    test "returns error when id is invalid" do
      # Test with a valid integer ID that doesn't exist
      assert {:error, "Dinosaur not found"} = Dinosaur.get_dinosaur(nil, %{id: "999999"}, nil)
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

    %DinosaurStruct{}
    |> DinosaurStruct.changeset(attrs)
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