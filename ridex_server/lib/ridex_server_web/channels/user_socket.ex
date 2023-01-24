defmodule RidexServerWeb.UserSocket do
  use Phoenix.Socket
  alias RidexServer.Guardian

  channel("cell:*", RidexServerWeb.CellChannel)
  channel("user:*", RidexServerWeb.UserChannel)

  def connect(%{"token" => token}, socket) do
    case Guardian.resource_from_token(token) do
      {:ok, user, _claims} ->
        {:ok, assign(socket, :current_user, user)}

      _ ->
        :error
    end
  end

  def connect(_params, _socket), do: :error

  def id(socket), do: socket.assigns[:current_user].id |> to_string()
end
