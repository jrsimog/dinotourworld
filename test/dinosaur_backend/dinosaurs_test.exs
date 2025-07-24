defmodule DinosaurBackend.DinosaursTest do
  use DinosaurBackend.DataCase

  alias DinosaurBackend.Dinosaurs
  alias DinosaurBackend.Dinosaurs.Dinosaur
  alias DinosaurBackend.Locations.Location
  alias DinosaurBackend.Findings.Finding

  describe "list_dinosaurs/0" do
    test "returns all dinosaurs" do
      dinosaur = insert_dinosaur()
      assert Dinosaurs.list_dinosaurs() == [dinosaur]
    end

    test "returns empty list when no dinosaurs exist" do
      assert Dinosaurs.list_dinosaurs() == []
    end
  end

  describe "get_dinosaur!/1" do
    test "returns the dinosaur with given id" do
      dinosaur = insert_dinosaur()
      assert Dinosaurs.get_dinosaur!(dinosaur.id) == dinosaur
    end

    test "raises Ecto.NoResultsError when dinosaur doesn't exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Dinosaurs.get_dinosaur!(999)
      end
    end
  end

  describe "create_dinosaur/1" do
    test "with valid data creates a dinosaur" do
      valid_attrs = %{
        name: "Tyrannosaurus Rex",
        description: "Large carnivorous dinosaur",
        species: "T. rex",
        era: "Cretaceous",
        latitude: 45.0,
        longitude: -110.0
      }

      assert {:ok, %Dinosaur{} = dinosaur} = Dinosaurs.create_dinosaur(valid_attrs)
      assert dinosaur.name == "Tyrannosaurus Rex"
      assert dinosaur.description == "Large carnivorous dinosaur"
      assert dinosaur.species == "T. rex"
      assert dinosaur.era == "Cretaceous"
      assert dinosaur.latitude == 45.0
      assert dinosaur.longitude == -110.0
    end

    test "with invalid data returns error changeset" do
      invalid_attrs = %{name: nil, description: nil, species: nil, era: nil}

      assert {:error, %Ecto.Changeset{}} = Dinosaurs.create_dinosaur(invalid_attrs)
    end
  end

  describe "update_dinosaur/2" do
    test "with valid data updates the dinosaur" do
      dinosaur = insert_dinosaur()
      update_attrs = %{
        name: "Updated Dinosaur",
        description: "Updated description"
      }

      assert {:ok, %Dinosaur{} = updated_dinosaur} = Dinosaurs.update_dinosaur(dinosaur, update_attrs)
      assert updated_dinosaur.name == "Updated Dinosaur"
      assert updated_dinosaur.description == "Updated description"
    end

    test "with invalid data returns error changeset" do
      dinosaur = insert_dinosaur()
      invalid_attrs = %{name: nil, description: nil}

      assert {:error, %Ecto.Changeset{}} = Dinosaurs.update_dinosaur(dinosaur, invalid_attrs)
      assert dinosaur == Dinosaurs.get_dinosaur!(dinosaur.id)
    end
  end

  describe "delete_dinosaur/1" do
    test "deletes the dinosaur" do
      dinosaur = insert_dinosaur()
      assert {:ok, %Dinosaur{}} = Dinosaurs.delete_dinosaur(dinosaur)
      assert_raise Ecto.NoResultsError, fn -> Dinosaurs.get_dinosaur!(dinosaur.id) end
    end
  end

  describe "change_dinosaur/1" do
    test "returns a dinosaur changeset" do
      dinosaur = insert_dinosaur()
      assert %Ecto.Changeset{} = Dinosaurs.change_dinosaur(dinosaur)
    end
  end

  # Helper function to create test data
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

    {:ok, dinosaur} = Dinosaurs.create_dinosaur(attrs)
    dinosaur
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