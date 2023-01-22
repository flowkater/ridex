defmodule RidexServerWeb.AuthenticationControllerTest do
  use RidexServerWeb.ConnCase

  describe "POST /api/authenticate" do
    test "returns OK with token", %{conn: conn} do
      body =
        conn
        |> post("/api/authenticate", %{
          "phone" => "+1234567890",
          "type" => "rider"
        })
        |> json_response(200)

      %{
        "id" => user_id,
        "token" => token,
        "type" => "rider"
      } = body

      assert {:ok, _} = RidexServer.Guardian.decode_and_verify(token, %{"sub" => user_id})
    end

    test "creates user", %{conn: conn} do
      body =
        conn
        |> post("/api/authenticate", %{
          "phone" => "+1234567890",
          "type" => "rider"
        })
        |> json_response(200)

      %{
        "id" => user_id
      } = body

      assert [%{id: new_user_id}] = RidexServer.User |> RidexServer.Repo.all()
      assert new_user_id == user_id
    end

    test "returns 400 with wrong user type", %{conn: conn} do
      conn
      |> post("/api/authenticate", %{
        "phone" => "+1234567890",
        "type" => "wrong"
      })
      |> json_response(400)
    end
  end
end
