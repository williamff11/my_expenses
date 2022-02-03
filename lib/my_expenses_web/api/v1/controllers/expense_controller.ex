defmodule MyExpensesWeb.Api.V1.Controllers.ExpenseController do
  @moduledoc false

  use MyExpensesWeb, :controller

  import Phoenix.Controller

  alias MyExpenses.Expenses

  action_fallback MyExpensesWeb.Api.FallbackController

  def index_expense_categories(conn, _params) do
    expense_categories = Expenses.list_expense_category()

    json(conn, expense_categories, 200)
  end

  def show_expense_category(conn, %{"id" => expense_category_id}) do
    expense = Expenses.get_expense_category(expense_category_id)

    json(conn, expense, 200)
  end

  def create_expense_category(conn, %{"expense_category" => expense_category_params}) do
    case Expenses.create_expense_category(expense_category_params) do
      {:ok, expense_category} -> json(conn, expense_category, 201)
      error -> error
    end
  end

  def update_expense_category(conn, %{"id" => expense_category_id, "expense_category" => expense_category_params}) do
    expense_category = Expenses.get_expense_category(expense_category_id)

    case Expenses.update_expense_category(expense_category, expense_category_params) do
      {:ok, expense_category} -> json(conn, expense_category, 200)
      error -> error
    end
  end

  def delete_expense_category(conn, %{"id" => expense_category_id}) do
    expense_category = Expenses.get_expense_category(expense_category_id)

    case Expenses.delete_expense_category(expense_category) do
      {:ok, expense_category} -> json(conn, expense_category, 204)
      error -> error
    end
  end

  def index_expenses(conn, _params) do
    user_id = get_user_id_by_conn(conn)
    expenses = Expenses.list_expenses_by(%{user_id: user_id})

    json(conn, expenses, 200)
  end

  def show_expense(conn, %{"id" => expense_id}) do
    user_id = get_user_id_by_conn(conn)

    expense = Expenses.get_expense_by(%{user_id: user_id, id: expense_id})

    json(conn, expense, 200)
  end

  def create_expense(conn, %{"expense" => expense_params}) do
    case Expenses.create_expense(expense_params) do
      {:ok, expense} -> json(conn, expense, 201)
      error -> error
    end
  end

  def update_expense(conn, %{"id" => expense_id, "expense" => expense_params}) do
    user_id = get_user_id_by_conn(conn)

    expense = Expenses.get_expense_by(%{user_id: user_id, id: expense_id})

    expense_params = Map.drop(expense_params, ["user_id"])

    case Expenses.update_expense(expense, expense_params) do
      {:ok, expense} -> json(conn, expense, 200)
      error -> error
    end
  end

  def delete_expense(conn, %{"id" => expense_id}) do
    user_id = get_user_id_by_conn(conn)

    expense = Expenses.get_expense_by(%{user_id: user_id, expense_id: expense_id})

    case Expenses.delete_expense(expense) do
      {:ok, expense} -> json(conn, expense, 204)
      error -> error
    end
  end
end
