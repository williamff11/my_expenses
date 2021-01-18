defmodule MyExpenses.Accounts.Query.AccountsQuery do
  @moduledoc """
  Módulo para queries do contexto de contas.
  """

  import Ecto.Query

  alias MyExpenses.Accounts.Schema

  def list_accounts_by(%{} = params) do
    conditions = build_filter(params)

    from acc in Schema.Account, where: ^conditions
  end

  defp build_filter(params) do
    %{user_id: user_id} = params

    Enum.reduce(params, dynamic([expense], expense.user_id == ^user_id), fn
      {:name, value}, dynamic ->
        like_value = "%" <> value <> "%"
        dynamic([expense], ^dynamic and like(expense.name, ^like_value))

      {:num_account, value}, dynamic ->
        dynamic([expense], ^dynamic and expense.num_account == ^value)

      {:type_account, value}, dynamic ->
        dynamic([expense], ^dynamic and expense.type_account == ^value)

      {:institution_id, value}, dynamic ->
        dynamic([expense], ^dynamic and expense.institution_id == ^value)

      {_, _}, dynamic ->
        dynamic
    end)
  end
end
