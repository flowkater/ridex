defmodule RidexServer.Ride do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rides" do
    field(:lat, :float)
    field(:lng, :float)
    field(:rider_id, :id)
    field(:driver_id, :id)

    timestamps()
  end

  def create(rider_id, driver_id, %{"lat" => lat, "lng" => lng}) do
    %RidexServer.Ride{
      rider_id: rider_id,
      driver_id: driver_id,
      lat: lat,
      lng: lng
    }
    |> RidexServer.Repo.insert()
  end

  @doc false
  def changeset(ride, attrs) do
    ride
    |> cast(attrs, [:lat, :lng])
    |> validate_required([:lat, :lng])
  end
end
