defmodule RidexServerWeb.PageController do
  use RidexServerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
