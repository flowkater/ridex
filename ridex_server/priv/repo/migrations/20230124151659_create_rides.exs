defmodule RidexServer.Repo.Migrations.CreateRides do
  use Ecto.Migration

  def change do
    create table(:rides) do
      add(:lat, :float)
      add(:lng, :float)
      add(:rider_id, references(:users, on_delete: :nothing))
      add(:driver_id, references(:users, on_delete: :nothing))

      timestamps()
    end

    create(index(:rides, [:rider_id]))
    create(index(:rides, [:driver_id]))
  end
end
