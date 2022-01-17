defmodule MyExpenses.Users do
  @moduledoc """
  Módulo responsável por cuidar da regra de negócio dos usuários.
  """

  alias MyExpenses.Users.Query
  alias MyExpenses.Users.Schema.User

  @type user_params() :: %{
          nome: String.t(),
          email: String.t(),
          telefone: String.t(),
          data_nascimento: Date.t(),
          cpf_cnpj: String.t(),
          login: String.t(),
          senha: String.t()
        }

  @type user_filter_params() :: [id: binary()]

  @type callback() :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}

  @doc """
  Lista usuário(s) conforme paramêtro
  """
  @spec list_users() :: [User.t()]
  def list_users do
    MyExpenses.Repo.all(Query.UserQuery.all_users())
  end

  @doc """
  Lista somente os usuários deletados
  """
  @spec list_only_trash() :: [%User{deleted_at: nil}]
  def list_only_trash do
    MyExpenses.Repo.all(Query.UserQuery.only_trash())
  end

  @doc """
  Cria um usuário conforme os parâmetros passados
  """
  @spec create_user(user_params()) :: callback()
  def create_user(%{} = params) do
    %User{}
    |> User.create_changeset(params)
    |> MyExpenses.Repo.insert()
  end

  @doc """
  Retorna o usuário com o id informado
  """
  @spec get_user(user_filter_params()) :: User.t() | nil
  def get_user(user_id) do
    Query.UserQuery.get_user(user_id)
    |> MyExpenses.Repo.one()
  end

  @doc """
  Retorna o usuário deletado com o id informado
  """
  @spec get_user_deleted(user_filter_params()) :: %User{deleted_at: nil} | nil
  def get_user_deleted(user_id) do
    Query.UserQuery.get_user_deleted(user_id)
    |> MyExpenses.Repo.one()
  end

  @doc """
  Retorna o Usuário informado com as devidas mudanças
  """
  @spec update_user(User.t(), user_params()) ::
          callback()
  def update_user(%User{} = user, %{} = params) do
    user
    |> User.update_changeset(params)
    |> MyExpenses.Repo.update()
  end

  @doc """
  Realiza a deletação lógica do usuário
  """
  @spec delete_user(User.t()) :: callback()
  def delete_user(%User{} = user) do
    deleted_at = DateTime.truncate(Timex.now(), :second)

    Ecto.Changeset.change(user, %{deleted_at: deleted_at})
    |> MyExpenses.Repo.update()
  end
end
