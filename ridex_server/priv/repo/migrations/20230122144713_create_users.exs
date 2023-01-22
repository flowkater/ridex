defmodule RidexServer.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :type, :string
      add :phone, :string

      timestamps()
    end
  end
end
