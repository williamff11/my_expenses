defmodule MyExpensesWeb.Api.V1.Controllers.AccountController do
  @moduledoc false

  use MyExpensesWeb, :controller

  import Phoenix.Controller

  alias MyExpenses.Accounts

  action_fallback MyExpensesWeb.Api.FallbackController

  def index(conn, _params) do
    user_id = get_user_id_by_conn(conn)
    accounts = Accounts.list_accounts_by(%{user_id: user_id})

    json(conn, accounts, 200)
  end

  def show(conn, %{"id" => account_id}) do
    user_id = get_user_id_by_conn(conn)

    account = Accounts.get_account(user_id, account_id)

    json(conn, account, 200)
  end

  def create(conn, %{"account" => account_params}) do
    user_id = get_user_id_by_conn(conn)

    case Accounts.create_account(user_id, account_params) do
      {:ok, account} -> json(conn, account, 201)
      error -> error
    end
  end

  def update(conn, %{"id" => account_id, "account" => account_params}) do
    user_id = get_user_id_by_conn(conn)

    account_params = Map.drop(account_params, ["user_id"])

    case Accounts.update_account(user_id, account_id, account_params) do
      {:ok, account} -> json(conn, account, 200)
      error -> error
    end
  end

  def delete(conn, %{"id" => account_id}) do
    user_id = get_user_id_by_conn(conn)

    case Accounts.delete_account(user_id, account_id) do
      {:ok, account} -> json(conn, account, 204)
      error -> error
    end
  end
end
