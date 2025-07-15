defmodule Bookbook.Repo do
  use Ecto.Repo,
    otp_app: :bookbook,
    adapter: Ecto.Adapters.Postgres
end
