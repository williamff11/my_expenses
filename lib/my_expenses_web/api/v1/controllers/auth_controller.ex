defmodule MyExpensesWeb.Api.V1.Controllers.AuthController do
  @moduledoc false

  use MyExpensesWeb, :controller

  import Phoenix.Controller

  alias MyExpenses.Auth

  action_fallback MyExpensesWeb.Api.FallbackController

  def login(conn, %{"credentials" => login_params}) do
    email = Map.get(login_params, "email")
    password = Map.get(login_params, "password")

    case Auth.do_login(email, password) do
      {:ok, result} -> json(conn, result, 200)
      {:error, error} -> json(conn, %{error: error}, 400)
    end
  end
end
