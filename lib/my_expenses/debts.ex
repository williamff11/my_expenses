defmodule MyExpenses.Debts do
  @moduledoc false

  alias MyExpenses.Debts.Schema
  alias MyExpenses.Debts.Query.DebtsQuery

  @type user_filter_params() :: [id: binary()]

  def list_category_debts do
    DebtsQuery.get_category_debts()
    |> MyExpenses.Repo.all()
  end

  @spec show_category_debt(user_filter_params()) ::
          Schema.CategoryDebts.t() | Ecto.NoResultsError
  def show_category_debt(category_id) do
    Schema.CategoryDebts
    |> MyExpenses.Repo.get(category_id)
  end

  def create_category_debt(params) do
    %Schema.CategoryDebts{}
    |> Schema.CategoryDebts.changeset(params)
    |> MyExpenses.Repo.insert()
  end
end
