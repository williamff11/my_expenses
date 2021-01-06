defmodule MyExpenses.Debts.Query.DebtsQuery do
  @moduledoc """
  Querys Debts
  """

  import Ecto.Query

  alias MyExpenses.Debts.Schema

  def get_category_debts do
    from(category_debt in Schema.CategoryDebts)
  end

  @doc """
  Filtra as dívidas do usuario conforme parâmetros informados.
  """
  @spec get_debts_by(%{
          user_id: UUID.t(),
          conta_id: UUID.t() | nil,
          category_debts_id: non_neg_integer() | nil
        }) :: Ecto.Query.t()
  def get_debts_by(params) do
    conditions = build_filter(params)

    from query in Schema.Debts, where: ^conditions
  end

  defp build_filter(params) do
    %{user_id: user_id} = params

    Enum.reduce(params, dynamic([debt], debt.user_id == ^user_id), fn
      {:conta_id, value}, dynamic ->
        dynamic([debt], ^dynamic and debt.conta_id == ^value)

      {:category_debts_id, value}, dynamic ->
        dynamic([debt], ^dynamic and debt.category_debts_id == ^value)

      {_, _}, dynamic ->
        dynamic
    end)
  end
end
