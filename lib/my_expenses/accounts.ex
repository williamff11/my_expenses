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
  Retorna uma lista de contas conforme os parametros passados.

  A key `user_id` é obrigatórias
  """
  @spec list_accounts_by(accounts_params) :: [] | [Schema.Account.t()]
  def list_accounts_by(%{} = params) do
    if not (:user_id in Map.keys(params)), do: raise("key user_id is required")

    AccountsQuery.list_accounts_by(params)
    |> MyExpenses.Repo.all()
    |> MyExpenses.Repo.preload(:institution)
  end
end
