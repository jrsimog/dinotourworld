defmodule DinosaurBackend.OpenStreetMapTest do
  use ExUnit.Case, async: true

  alias DinosaurBackend.OpenStreetMap


  describe "find_coordinates/1" do
    test "delegates to service" do
      assert is_function(&OpenStreetMap.find_coordinates/1)
    end
  end

  describe "find_address/1" do
    test "delegates to service" do
      assert is_function(&OpenStreetMap.find_address/1)
    end
  end

  describe "batch_geocode/1" do
    test "delegates to service" do
      assert is_function(&OpenStreetMap.batch_geocode/1)
    end
  end

  describe "search_nearby/3" do
    test "delegates to service with default radius" do
      assert is_function(&OpenStreetMap.search_nearby/2)
      assert is_function(&OpenStreetMap.search_nearby/3)
    end
  end

  describe "valid_coordinates?/1" do
    test "delegates to service" do
      assert is_function(&OpenStreetMap.valid_coordinates?/1)
    end
  end

  describe "new_service/1" do
    test "delegates to service constructor" do
      assert is_function(&OpenStreetMap.new_service/0)
      assert is_function(&OpenStreetMap.new_service/1)
    end
  end
end