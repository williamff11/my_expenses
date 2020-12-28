defmodule MyExpenses.Debts do
  @moduledoc """
  Módulo responsável pela regra de negócio do contexto de dívidas
  """

  alias MyExpenses.Debts.Query.DebtsQuery
  alias MyExpenses.Debts.Schema

  @type category_debt_params() :: %{
          name: String.t(),
          description: String.t(),
          icon: String.t(),
          color: String.t()
        }

  @type category_debt_filter_params() :: [id: binary()]

  @type callback() :: {:ok, Schema.CategoryDebts.t()} | {:error, Ecto.Changeset.t()}

  @doc """
  Lista todas as categorias de dívidas.
  """
  @spec list_category_debts() :: [Schema.CategoryDebts.t()] | nil
  def list_category_debts do
    DebtsQuery.get_category_debts()
    |> MyExpenses.Repo.all()
  end

  def list_category_debts_by_user do
    :not_implemented
  end

  @doc """
  Mostra a categoria de dívida pertencente ao id informado.
  """
  @spec show_category_debt(category_debt_filter_params()) :: Schema.CategoryDebts.t() | nil
  def show_category_debt(category_id) do
    Schema.CategoryDebts
    |> MyExpenses.Repo.get(category_id)
  end

  @doc """
  Cria uma nova categoria de dívida conforme os parâmetros informados.
  """
  @spec create_category_debt(category_debt_params()) :: callback()
  def create_category_debt(params) do
    %Schema.CategoryDebts{}
    |> Schema.CategoryDebts.changeset(params)
    |> MyExpenses.Repo.insert()
  end

  @doc """
  Atualiza a categoria de dívida informada conforme os parâmetros informados.
  """
  @spec update_category_debt(Schema.CategoryDebts.t(), category_debt_params()) :: callback()
  def update_category_debt(%Schema.CategoryDebts{} = category_debt, %{} = params) do
    category_debt
    |> Schema.CategoryDebts.changeset(params)
    |> MyExpenses.Repo.update()
  end

  @doc """
  Deleta a categoria de dívida informada.
  """
  @spec delete_category_debt(id: non_neg_integer()) :: callback()
  def delete_category_debt(category_debt_id) do
    Schema.CategoryDebts
    |> MyExpenses.Repo.get!(category_debt_id)
    |> MyExpenses.Repo.delete()
  end
end
