defmodule MyExpensesWeb.Api.V1.Controllers.UserController do
  @moduledoc false

  use MyExpensesWeb, :controller

  import Phoenix.Controller

  alias MyExpenses.Users

  action_fallback MyExpensesWeb.Api.FallbackController

  def index(conn, _params) do
    users = Users.list_users()

    json(conn, users, 200)
  end

  def show(conn, %{"id" => user_id}) do
    account = Users.get_user(user_id)

    json(conn, account, 200)
  end

  def create(conn, %{"user" => user_params}) do
    case Users.create_user(user_params) do
      {:ok, account} -> json(conn, account, 201)
      error -> error
    end
  end

  def update(conn, %{"id" => user_id, "user" => user_params}) do
    user = Users.get_user(user_id)

    case Users.update_user(user, user_params) do
      {:ok, account} -> json(conn, account, 200)
      error -> error
    end
  end

  def delete(conn, %{"id" => user_id}) do
    user = Users.get_user(user_id)

    case Users.delete_user(user) do
      {:ok, account} -> json(conn, account, 204)
      error -> error
    end
  end
end
