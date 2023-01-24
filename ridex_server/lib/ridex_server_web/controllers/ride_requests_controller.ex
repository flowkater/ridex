defmodule RidexServerWeb.RideRequestsController do
  use RidexServerWeb, :controller

  def create(
        conn,
        %{
          "geohash" => geohash,
          "position" => position
        } = params
      ) do
    rider = conn.assigns[:current_user]

    case RidexServer.RideRequest.create(rider, position) do
      {:ok, request} ->
        RidexServerWeb.Endpoint.broadcast("cell:#{geohash}", "ride:requested", %{
          request_id: request.id,
          position: position
        })

        conn |> json(%{"request" => request})

      {:error, _reason} ->
        conn |> json(%{"error" => "Unable to request a ride"})
    end
  end
end
