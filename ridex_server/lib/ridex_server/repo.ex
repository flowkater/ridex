defmodule RidexServer.Repo do
  use Ecto.Repo,
    otp_app: :ridex_server,
    adapter: Ecto.Adapters.Postgres
end
