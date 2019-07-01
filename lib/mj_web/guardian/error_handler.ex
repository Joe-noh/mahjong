defmodule MjWeb.Guardian.ErrorHandler do
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    body = %{message: to_string(type)} |> Jason.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, body)
  end
end