defmodule MyExpenses.Expenses.Query.ExpensesQuery do
  @moduledoc """
  Querys Expenses
  """

  import Ecto.Query

  alias MyExpenses.Expenses.Schema

  def get_expense_categorys do
    from(expenses_category in Schema.ExpenseCategory)
  end

  @doc """
  Filtra os gastos do usuario conforme parâmetros informados.
  """
  @spec get_expenses_by(%{
          user_id: UUID.t(),
          conta_id: UUID.t() | nil,
          expenses_category: non_neg_integer() | nil
        }) :: Ecto.Query.t()
  def get_expenses_by(%{} = params) do
    conditions = build_filter(params)

    from query in Schema.Expense, where: ^conditions
  end

  def get_expenses_fixed_by() do
    from expense in Schema.Expense, where: expense.fix == true
  end

  defp build_filter(params) do
    %{user_id: user_id} = params

    Enum.reduce(params, dynamic([expense], expense.user_id == ^user_id), fn
      {:conta_id, value}, dynamic ->
        dynamic([expense], ^dynamic and expense.conta_id == ^value)

      {:expenses_category_id, value}, dynamic ->
        dynamic([expense], ^dynamic and expense.expenses_category_id == ^value)

      {_, _}, dynamic ->
        dynamic
    end)
  end
end
