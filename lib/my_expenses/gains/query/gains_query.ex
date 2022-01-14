defmodule MyExpenses.Gains.Query.GainsQuery do
  @moduledoc """
  Módulo responsável por construir as query do contexto.
  """

  import Ecto.Query

  alias MyExpenses.Gains.Schema

  def get_gain_by(params) do
    conditions = build_filter(params)

    from query in Schema.Gain, where: ^conditions
  end

  defp build_filter(params) do
    Enum.reduce(params, dynamic([gain], true == true), fn
      {:id, value}, dynamic ->
        dynamic([gain], ^dynamic and gain.id == ^value)

      {:account_id, value}, dynamic ->
        dynamic([gain], ^dynamic and gain.account_id == ^value)

      {:user_id, value}, dynamic ->
        dynamic([gain], ^dynamic and gain.user_id == ^value)

      {:frequency, value}, dynamic ->
        dynamic([gain], ^dynamic and gain.frequency == ^value)

      {:gains_category_id, value}, dynamic ->
        dynamic([gain], ^dynamic and gain.gains_category_id == ^value)

      {:fix, value}, dynamic ->
        dynamic([gain], ^dynamic and gain.fix == ^value)

      {:deleted_at, false}, dynamic ->
        dynamic([gain], ^dynamic and is_nil(gain.deleted_at))

      {:deleted_at, true}, dynamic ->
        dynamic([gain], ^dynamic and not is_nil(gain.deleted_at))

      {_, _}, dynamic ->
        dynamic
    end)
  end
end
