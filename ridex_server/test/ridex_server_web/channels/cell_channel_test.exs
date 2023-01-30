defmodule RidexServerWeb.CellChannelTest do
  use RidexServerWeb.ChannelCase, async: true
  alias RidexServer.User
  alias RidexServerWeb.{UserSocket, CellChannel}

  setup do
    {:ok, rider} = User.get_or_create("+1234567890", "rider", 37.5257048, 126.8877295)
    {:ok, driver} = User.get_or_create("+1234567891", "driver", 37.5257048, 126.8877295)

    {:ok, _, rider_socket} =
      UserSocket
      |> socket(rider.id, %{current_user: rider})
      |> subscribe_and_join(CellChannel, "cell:xyz")

    {:ok, _, driver_socket} =
      UserSocket
      |> socket(driver.id, %{current_user: driver})
      |> subscribe_and_join(CellChannel, "cell:xyz")

    %{
      rider_socket: rider_socket,
      driver_socket: driver_socket,
      rider: rider,
      driver: driver
    }
  end

  test "create ride request", %{
    rider_socket: rider_socket
  } do
    position = %{"lat" => 51.36577, "lng" => 0.6476747}

    ref = push(rider_socket, "ride:request", %{position: position})
    assert_reply(ref, :ok, %{})

    [request] = RidexServer.RideRequest |> RidexServer.Repo.all()

    assert request.lat == position["lat"]
    assert request.lng == position["lng"]
  end

  test "broadcast ride reqeust message", %{
    rider_socket: rider_socket
  } do
    position = %{"lat" => 51.36577, "lng" => 0.6476747}

    ref = push(rider_socket, "ride:request", %{position: position})
    assert_reply(ref, :ok, %{})

    [%{id: request_id}] = RidexServer.RideRequest |> RidexServer.Repo.all()

    assert_broadcast("ride:requested", %{
      request_id: request_id,
      position: position
    })
  end

  test "accepts ride request and creates ride", %{
    driver_socket: driver_socket,
    rider: rider,
    driver: driver
  } do
    position = %{"lat" => 51.36577, "lng" => 0.6476747}
    {:ok, request} = RidexServer.RideRequest.create(rider, position)

    ref =
      push(driver_socket, "ride:accept_request", %{
        request_id: request.id
      })

    assert_reply(ref, :ok, %{})

    assert [ride] = RidexServer.Ride |> RidexServer.Repo.all()
    assert ride.rider_id == rider.id
    assert ride.driver_id == driver.id
  end

  test "fail to accept non existing ride request", %{
    driver_socket: driver_socket
  } do
    ref = push(driver_socket, "ride:accept_request", %{request_id: 123})
    assert_reply(ref, :error, %{})

    assert [] = RidexServer.Ride |> RidexServer.Repo.all()
  end

  test "broadcasts ride:created to both users", %{
    driver_socket: driver_socket,
    rider: rider,
    driver: driver
  } do
    Phoenix.PubSub.subscribe(RidexServer.PubSub, "user:#{rider.id}")
    Phoenix.PubSub.subscribe(RidexServer.PubSub, "user:#{driver.id}")
    position = %{"lat" => 51.36577, "lng" => 0.6476747}
    {:ok, request} = RidexServer.RideRequest.create(rider, position)

    ref = push(driver_socket, "ride:accept_request", %{request_id: request.id})
    assert_reply(ref, :ok, %{})

    [%{id: ride_id}] = RidexServer.Ride |> RidexServer.Repo.all()

    assert_receive %Phoenix.Socket.Broadcast{
      event: "ride:created",
      payload: %{ride_id: ride_id}
    }

    assert_receive %Phoenix.Socket.Broadcast{
      event: "ride:created",
      payload: %{ride_id: ride_id}
    }
  end
end
