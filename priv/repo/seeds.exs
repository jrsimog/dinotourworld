alias DinosaurBackend.Repo
alias DinosaurBackend.Dinosaurs.Dinosaur
alias DinosaurBackend.Locations.Location
alias DinosaurBackend.Findings.Finding

# Clean slate
Repo.delete_all(Finding)
Repo.delete_all(Location)
Repo.delete_all(Dinosaur)

# Dinosaurs
{:ok, t_rex} =
  Dinosaur.changeset(%Dinosaur{}, %{
    name: "Tyrannosaurus Rex",
    description: "The king of the dinosaurs.",
    species: "Tyrannosaurus",
    era: "Cretaceous",
    latitude: 46.8797,
    longitude: -103.3622
  })
  |> Repo.insert()

{:ok, velociraptor} =
  Dinosaur.changeset(%Dinosaur{}, %{
    name: "Velociraptor",
    description: "A small, fast, and intelligent predator.",
    species: "Velociraptor",
    era: "Cretaceous",
    latitude: 44.0,
    longitude: 103.0
  })
  |> Repo.insert()

{:ok, triceratops} =
  Dinosaur.changeset(%Dinosaur{}, %{
    name: "Triceratops",
    description: "A large, herbivorous dinosaur with three horns.",
    species: "Triceratops",
    era: "Cretaceous",
    latitude: 40.5853,
    longitude: -105.0844
  })
  |> Repo.insert()

# Locations
{:ok, montana} =
  Location.changeset(%Location{}, %{
    city: "Hell Creek",
    country: "USA",
    latitude: 47.5,
    longitude: -106.5
  })
  |> Repo.insert()

{:ok, mongolia} =
  Location.changeset(%Location{}, %{
    city: "Gobi Desert",
    country: "Mongolia",
    latitude: 43.0,
    longitude: 105.0
  })
  |> Repo.insert()

# Findings
Finding.changeset(%Finding{}, %{
  dinosaur_id: t_rex.id,
  location_id: montana.id,
  year: 1902,
  source: "Barnum Brown"
})
|> Repo.insert()

Finding.changeset(%Finding{}, %{
  dinosaur_id: velociraptor.id,
  location_id: mongolia.id,
  year: 1923,
  source: "Peter Kaisen"
})
|> Repo.insert()

Finding.changeset(%Finding{}, %{
  dinosaur_id: triceratops.id,
  location_id: montana.id,
  year: 1887,
  source: "John Bell Hatcher"
})
|> Repo.insert()

IO.puts("Seed data created successfully!")
