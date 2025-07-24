defmodule DinosaurBackend.Repo do
  use Ecto.Repo,
    otp_app: :dinosaur_backend,
    adapter: Ecto.Adapters.Postgres
end
