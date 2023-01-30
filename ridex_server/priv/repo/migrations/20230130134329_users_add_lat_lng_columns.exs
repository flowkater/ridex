defmodule RidexServer.Repo.Migrations.UsersAddLatLngColumns do
  use Ecto.Migration

  def change do
    alter table("users") do
      add(:lat, :float)
      add(:lng, :float)
    end
  end
end
