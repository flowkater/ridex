defmodule RidexServerWeb.CellChannel do
  use RidexServerWeb, :channel

  intercept(["ride:requested"])

  def join("cell:" <> _geohash, %{"position" => position}, socket) do
    user = socket.assigns[:current_user]
    send(self(), {:after_join, position})

    {:ok, socket}
  end

  def handle_info({:after_join, position}, socket) do
    user = socket.assigns[:current_user]

    if user.type == "driver" do
      RidexServerWeb.Presence.track(socket, user.id, %{
        lat: position["lat"],
        lng: position["lng"]
      })
    end

    push(socket, "presence_state", RidexServerWeb.Presence.list(socket))

    {:noreply, socket}
  end

  def handle_in("update_position", %{"lat" => lat, "lng" => lng}, socket) do
    user = socket.assigns[:current_user]

    RidexServerWeb.Presence.update(socket, user.id, %{
      lat: lat,
      lng: lng
    })

    {:noreply, socket}
  end

  def handle_in(
        "ride:request",
        %{
          "position" => position
        },
        socket
      ) do
    case RidexServer.RideRequest.create(socket.assigns[:current_user], position) do
      {:ok, request} ->
        broadcast!(socket, "ride:requested", %{
          request_id: request.id,
          position: position
        })

        {:reply, :ok, socket}

      {:error, _changeset} ->
        {:reply, {:error, :insert_error}, socket}
    end
  end

  def handle_in("ride:accept_request", %{"request_id" => request_id}, socket) do
    case RidexServer.Repo.get(RidexServer.RideRequest, request_id) do
      nil ->
        {:reply, :error, socket}

      request ->
        case RidexServer.Ride.create(
               request.rider_id,
               socket.assigns[:current_user].id,
               %{
                 "lat" => request.lat,
                 "lng" => request.lng
               }
             ) do
          {:ok, ride} ->
            RidexServerWeb.Endpoint.broadcast(
              "user:#{ride.rider_id}",
              "ride:created",
              %{
                ride_id: ride.id,
                position: %{
                  "lat" => ride.lat,
                  "lng" => ride.lng
                }
              }
            )

            RidexServerWeb.Endpoint.broadcast(
              "user:#{ride.driver_id}",
              "ride:created",
              %{
                ride_id: ride.id,
                position: %{
                  "lat" => ride.lat,
                  "lng" => ride.lng
                }
              }
            )

            {:reply, :ok, socket}

          {:error, _changeset} ->
            {:reply, :error, socket}
        end
    end
  end

  def handle_out("ride:requested", payload, socket) do
    if socket.assigns[:current_user].type == "driver" do
      IO.puts("to driver Ride requested: #{inspect(payload)}")
      push(socket, "ride:requested", payload)
    end

    {:noreply, socket}
  end
end
