defmodule DinosaurBackend.Dinosaurs do
  @moduledoc "Contexto para dinosaurios"

  import Ecto.Query, warn: false
  alias DinosaurBackend.Repo

  alias DinosaurBackend.Dinosaurs.Dinosaur

  def list_dinosaurs do
    Repo.all(Dinosaur)
  end

  def get_dinosaur!(id), do: Repo.get!(Dinosaur, id)

  def create_dinosaur(attrs \\ %{}) do
    %Dinosaur{}
    |> Dinosaur.changeset(attrs)
    |> Repo.insert()
  end

  def update_dinosaur(%Dinosaur{} = dinosaur, attrs) do
    dinosaur
    |> Dinosaur.changeset(attrs)
    |> Repo.update()
  end

  def delete_dinosaur(%Dinosaur{} = dinosaur), do: Repo.delete(dinosaur)

  def change_dinosaur(%Dinosaur{} = dinosaur), do: Dinosaur.changeset(dinosaur, %{})
end
