defmodule RidexServerWeb.AuthenticationController do
  use RidexServerWeb, :controller
  alias RidexServer.User

  plug :validate_user_type

  def authenticate(conn, %{"phone" => phone, "type" => type}) do
    with {:ok, user} <- User.get_or_create(phone, type),
         {:ok, token, _claims} = RidexServer.Guardian.encode_and_sign(user) do
      conn
      |> json(%{
        "id" => user.id,
        "token" => token,
        "type" => type
      })
    else
      {:error, reason} ->
        conn
        |> json(%{"error" => "Error authenticating: #{reason}"})
    end
  end

  def validate_user_type(conn, _) do
    case conn.params["type"] do
      type when type in ["rider", "driver"] ->
        conn

      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{"error" => "Invalid user type"})
        |> halt()
    end
  end
end
