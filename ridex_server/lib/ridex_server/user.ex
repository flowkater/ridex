defmodule RidexServer.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias RidexServer.User

  schema "users" do
    field :phone, :string
    field :type, :string

    timestamps()
  end

  def get_or_create(phone, type) do
    case RidexServer.Repo.get_by(User, phone: phone, type: type) do
      nil ->
        %User{phone: phone, type: type}
        |> RidexServer.Repo.insert()

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
