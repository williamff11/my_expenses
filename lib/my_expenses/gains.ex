defmodule MyExpenses.Gains do
  @moduledoc """
  Módulo responsável pelos Ganhos
  """
  import Ecto.Query

  alias MyExpenses.Gains.Schema
  alias MyExpenses.Gains.Query.GainsQuery

  @type gain_category_filter_params() :: [id: non_neg_integer()]

  @type gain_category_params() :: %{
          name: String.t(),
          description: String.t(),
          icon: String.t(),
          color: String.t()
        }

  @doc """
  Retorna uma lista de categoria de ganhos
  """
  @spec list_gains_category :: [%Schema.GainCategory{}] | nil
  def list_gains_category do
    MyExpenses.Repo.all(Schema.GainCategory)
  end

  @doc """
  Retorna uma categoria de gastos conforme id informado
  """
  @spec show_gain_category(gain_category_filter_params) :: %Schema.GainCategory{} | nil
  def show_gain_category(category_id) do
    Schema.GainCategory
    |> MyExpenses.Repo.get(category_id)
  end

  @doc """
  Cria uma categoria conforme os parametros informados.
  """
  @spec create_gain_category(gain_category_params) :: %Schema.GainCategory{} | Ecto.Changeset.t()
  def create_gain_category(params) do
    %Schema.GainCategory{}
    |> Schema.GainCategory.changeset(params)
    |> MyExpenses.Repo.insert()
  end

  @doc """
  Atualiza uma categoria conforme os paramentros infomados
  """
  @spec update_gain_category(%Schema.GainCategory{}, gain_category_params()) ::
          {:ok, %Schema.GainCategory{}} | {:error, Ecto.Changeset.t()}
  def update_gain_category(%Schema.GainCategory{} = category, params) do
    category
    |> Schema.GainCategory.changeset(params)
    |> MyExpenses.Repo.update()
  end

  @doc """
  Deleta uma categoria de gastos conforme id informado
  """
  def delete_gain_category(category_id) do
    Schema.GainCategory
    |> MyExpenses.Repo.get!(category_id)
    |> MyExpenses.Repo.delete()
  end

  @doc """
  Lista os ganhos apartir dos paramêtros
  """
  def list_gains_by(params) do
    if not (:user_id in Map.keys(params)), do: raise("Key user_id is required")

    params
    |> GainsQuery.get_gain_by()
    |> preload(:gain_category)
    |> MyExpenses.Repo.all()
  end

  @doc """
  Retorna o ganho conforme o id informado.
  """
  def show_gain(id) do
    MyExpenses.Repo.get(Schema.Gain, id)
  end

  def create_gain(%Schema.GainCategory{} = gain_category, params) do
    %Schema.Gain{
      gain_category_id: gain_category.id
    }
    |> Schema.Gain.create_changeset(params)
    |> MyExpenses.Repo.insert()
  end
end
