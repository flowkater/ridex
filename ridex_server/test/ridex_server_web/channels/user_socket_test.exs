defmodule RidexServerWeb.UserSocketTest do
  use RidexServerWeb.ChannelCase, async: true
  alias RidexServerWeb.UserSocket
  alias RidexServer.{User, Guardian}

  test "fail to authenticate without token" do
    assert :error = connect(UserSocket, %{})
  end

  test "failt o authenticate with invalid token" do
    assert :error = connect(UserSocket, %{"token" => "abcdef"})
  end

  test "authenticate and assign user ID with valid token" do
    {:ok, user} = User.get_or_create("+1234567890", "rider", 37.5257048, 126.8877295)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)

    assert {:ok, socket} = connect(UserSocket, %{"token" => token})
    assert socket.assigns.current_user.id == user.id
  end
end
