defmodule RidexServer.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias RidexServer.User

  schema "users" do
    field(:phone, :string)
    field(:type, :string)
    field(:lat, :float)
    field(:lng, :float)

    timestamps()
  end

  def get_or_create(phone, type, lat, lng) do
    case RidexServer.Repo.get_by(User, phone: phone, type: type) do
      nil ->
        %User{phone: phone, type: type, lat: lat, lng: lng}
        |> RidexServer.Repo.insert()

      user ->
        {:ok, user}
    end
  end

  def get(phone, type) do
    case RidexServer.Repo.get_by(User, phone: phone, type: type) do
      nil ->
        {:error, "User not found"}

      user ->
        {:ok, user}
    end
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:type, :phone])
    |> validate_required([:type, :phone])
  end
end
