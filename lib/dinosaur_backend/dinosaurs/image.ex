defmodule DinosaurBackend.Dinosaurs.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dinosaur_images" do
    field :url, :string
    field :caption, :string
    field :dinosaur_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:url, :caption])
    |> validate_required([:url, :caption])
  end
end
