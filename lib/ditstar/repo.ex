defmodule Ditstar.Repo do
  use Ecto.Repo,
    otp_app: :ditstar,
    adapter: Ecto.Adapters.Postgres
end
