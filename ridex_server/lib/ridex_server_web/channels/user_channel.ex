defmodule RidexServerWeb.UserChannel do
  use RidexServerWeb, :channel

  def join("user:" <> user_id, _params, socket) do
    %{id: id} = socket.assigns[:current_user]

    if id == String.to_integer(user_id),
      do: {:ok, socket},
      else: {:error, :unathorized}
  end
end
