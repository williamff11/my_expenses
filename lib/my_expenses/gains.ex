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
  @spec list_gain_categories :: [%Schema.GainCategory{}] | nil
  def list_gain_categories, do: MyExpenses.Repo.all(Schema.GainCategory)

  @doc """
  Retorna uma categoria de gastos conforme id informado
  """
  @spec get_gain_category(gain_category_filter_params) :: %Schema.GainCategory{} | nil
  def get_gain_category(category_id), do: MyExpenses.Repo.get(Schema.GainCategory, category_id)

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
  def delete_gain_category(%Schema.GainCategory{} = category), do: MyExpenses.Repo.delete(category)

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
  def get_gain(id), do: MyExpenses.Repo.get(Schema.Gain, id)

  def get_gain_by(params) do
    params
    |> GainsQuery.get_gain_by()
    |> MyExpenses.Repo.one()
  end

  def create_gain(params) do
    %Schema.Gain{}
    |> Schema.Gain.create_changeset(params)
    |> MyExpenses.Repo.insert()
  end

  def update_gain(%Schema.Gain{} = gain, params) do
    gain
    |> Schema.Gain.update_changeset(params)
    |> MyExpenses.Repo.update()
  end

  def delete_gain(%Schema.Gain{} = gain) do
    deleted_at = DateTime.truncate(Timex.now(), :second)

    gain
    |> Ecto.Changeset.change(%{deleted_at: deleted_at})
    |> MyExpenses.Repo.update()
  end
end
