defmodule RidexServer.Repo.Migrations.CreateRideRequests do
  use Ecto.Migration

  def change do
    create table(:ride_requests) do
      add(:lat, :float)
      add(:lng, :float)
      add(:rider_id, references(:users, on_delete: :nothing))

      timestamps()
    end

    create(index(:ride_requests, [:rider_id]))
  end
end
