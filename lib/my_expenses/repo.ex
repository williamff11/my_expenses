defmodule MyExpenses.Repo do
  use Ecto.Repo,
    otp_app: :my_expenses,
    adapter: Ecto.Adapters.Postgres
end
