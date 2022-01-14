defmodule MyExpenses.Expenses.Query.ExpensesQuery do
  @moduledoc """
  Querys Expenses
  """

  import Ecto.Query

  alias MyExpenses.Expenses.Schema

  def get_expense_categories do
    from(expenses_category in Schema.ExpenseCategory)
  end

  @doc """
  Filtra os gastos do usuario conforme parâmetros informados.
  """
  @spec get_expenses_by(%{
          user_id: UUID.t(),
          account_id: UUID.t() | nil,
          expenses_category: non_neg_integer() | nil
        }) :: Ecto.Query.t()
  def get_expenses_by(%{} = params) do
    conditions = build_filter(params)

    from query in Schema.Expense, where: ^conditions
  end

  def get_expenses_fixed_by(params \\ %{}) do
    if params == %{} do
      from expense in Schema.Expense, where: expense.fix? == true
    else
      conditions = build_filter(params)

      from expense in Schema.Expense, where: ^conditions
    end
  end

  defp build_filter(params) do
    Enum.reduce(params, dynamic([expense], true == true), fn
      {:id, value}, dynamic ->
        dynamic([expense], ^dynamic and expense.id == ^value)

      {:account_id, value}, dynamic ->
        dynamic([expense], ^dynamic and expense.account_id == ^value)

      {:user_id, value}, dynamic ->
        dynamic([expense], ^dynamic and expense.user_id == ^value)

      {:frequency, value}, dynamic ->
        dynamic([expense], ^dynamic and expense.frequency == ^value)

      {:expenses_category_id, value}, dynamic ->
        dynamic([expense], ^dynamic and expense.expenses_category_id == ^value)

      {:fix?, value}, dynamic ->
        dynamic([expense], ^dynamic and expense.fix? == ^value)

      {:deleted_at, false}, dynamic ->
        dynamic([expense], ^dynamic and is_nil(expense.deleted_at))

      {:deleted_at, true}, dynamic ->
        dynamic([expense], ^dynamic and not is_nil(expense.deleted_at))

      {_, _}, dynamic ->
        dynamic
    end)
  end
end
