defmodule MahWeb.ParticipationControllerTest do
  use MahWeb.ConnCase, async: true

  describe "declare participation" do
    setup %{conn: conn} do
      {:ok, user} = Fixtures.create(:user)
      conn = TestHelpers.Session.login(conn, user)

      %{conn: conn, user: user}
    end

    test "returns a game_id", %{conn: conn} do
      json =
        conn
        |> post(Routes.participation_path(conn, :create))
        |> json_response(201)

      assert %{"game_id" => _} = json["data"]
    end

    test "duplicated participation returns the same game_id", %{conn: conn} do
      game_id =
        conn
        |> post(Routes.participation_path(conn, :create))
        |> json_response(201)
        |> get_in(~w[data game_id])

      ^game_id =
        conn
        |> post(Routes.participation_path(conn, :create))
        |> json_response(201)
        |> get_in(~w[data game_id])
    end

    test "requires login", %{conn: conn} do
      conn
      |> TestHelpers.Session.logout()
      |> post(Routes.participation_path(conn, :create))
      |> json_response(401)
    end
  end
end
