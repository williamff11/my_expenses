defmodule MyExpenses.Accounts.Query.AccountsQuery do
  @moduledoc """
  Módulo para queries do contexto de contas.
  """

  import Ecto.Query

  alias MyExpenses.Accounts.Schema

  @type account_quey_params() :: %{
          user_id: UUID.t(),
          name: String.t(),
          num_account: String.t(),
          type_account: :corrente | :poupanca | :salario | :investimento,
          institution_id: non_neg_integer()
        }

  @doc """
  Retorna uma conta conforme os parâmetros informados.

  Espera um map como parâmetro.
  """
  @spec list_accounts_by(account_quey_params()) :: [%Schema.Account{}] | nil
  def list_accounts_by(%{} = params) do
    conditions = build_filter(params)

    from acc in Schema.Account, where: ^conditions
  end

  def get_account(user_id, account_id) do
    from acc in Schema.Account, where: acc.user_id == ^user_id and acc.id == ^account_id
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
