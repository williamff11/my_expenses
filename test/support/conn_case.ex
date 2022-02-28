defmodule MyExpensesWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use MyExpensesWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import MyExpensesWeb.ConnCase

      alias MyExpensesWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint MyExpensesWeb.Endpoint
    end
  end

  setup tags do
    :ok = Sandbox.checkout(MyExpenses.Repo)

    unless tags[:async] do
      Sandbox.mode(MyExpenses.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def authenticated(conn, user) do
    token =
      :my_expenses
      |> Application.get_env(MyExpensesWeb.Auth)
      |> Keyword.fetch!(:secret_key)
      |> generate_token_jwt(user)

    Plug.Conn.put_req_header(conn, "authorization", "Bearer #{token}")
  end

  def basic_auth(conn, token) do
    Plug.Conn.put_req_header(conn, "authorization", "Basic " <> Base.encode64(token))
  end

  defp generate_token_jwt(secret, user, params \\ %{}) do
    expiration_in_millis = :os.system_time(:millisecond) + :timer.minutes(15)

    params =
      Enum.into(params, %{
        "user" => user.id,
        "exp" => expiration_in_millis / 1000
      })

    secret
    |> JOSE.JWK.from_oct()
    |> JOSE.JWT.sign(%{"alg" => "HS256"}, params)
    |> JOSE.JWS.compact()
    |> elem(1)
  end
end
