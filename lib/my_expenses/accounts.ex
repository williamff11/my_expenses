defmodule MyExpenses.Accounts do
  @moduledoc """
  Regras de negócio do contexto de contas.
  """

  alias MyExpenses.Accounts.Query.AccountsQuery
  alias MyExpenses.Accounts.Schema

  @type accounts_params() :: %{
          nome: String.t(),
          num_conta: String.t(),
          type_account: atom(),
          user_id: UUID.t(),
          institution_id: non_neg_integer()
        }

  @doc """
  Lista todas as instituições financeiras cadastradas no sistema.
  """
  @spec list_institutions :: [%Schema.Institution{}] | nil
  def list_institutions do
    MyExpenses.Repo.all(Schema.Institution)
  end

  @doc """
  Retorna uma lista de contas conforme os parametros passados.

  A key `user_id` é obrigatória.
  """
  @spec list_accounts_by(accounts_params) :: [] | [Schema.Account.t()]
  def list_accounts_by(%{} = params) do
    if not (:user_id in Map.keys(params)), do: raise("key user_id is required")

    AccountsQuery.list_accounts_by(params)
    |> MyExpenses.Repo.all()
    |> MyExpenses.Repo.preload(:institution)
  end

  @doc """
  Retorna a conta caso o id do usuário seja o mesmo que a conta informada via id.
  """
  @spec show_account(UUID.t(), UUID.t()) :: Schema.Account.t() | nil
  def show_account(user_id, account_id) do
    user_id
    |> AccountsQuery.get_account(account_id)
    |> MyExpenses.Repo.one()
  end

  @doc """
  Cria uma conta conforme os parâmetros informados.
  """
  @spec create_account(UUID.t(), %{}) ::
          {:ok, Schema.Account.t()} | {:error, Ecto.Changeset.error()}
  def create_account(user_id, %{} = params) do
    %Schema.Account{user_id: user_id}
    |> Schema.Account.changeset(params)
    |> MyExpenses.Repo.insert()
  end

  @doc """
  Atualiza uma conta conforme os parâmetros informados.
  """
  @spec update_account(UUID.t(), UUID.t(), %{}) ::
          {:ok, Schema.Account.t()} | {:error, Ecto.Changeset.error()}
  def update_account(user_id, account_id, %{} = params) do
    account = show_account(user_id, account_id)

    if account == nil, do: raise("account not found")

    account
    |> Schema.Account.changeset(params)
    |> MyExpenses.Repo.update()
  end

  @doc """
  Deleta uma conta conforme os parâmetros informados.
  """
  @spec delete_account(UUID.t(), UUID.t()) :: {:ok, Schema.Account.t()}
  def delete_account(user_id, account_id) do
    account = show_account(user_id, account_id)

    if account == nil, do: raise("account not found")

    account
    |> MyExpenses.Repo.delete()
  end
end
