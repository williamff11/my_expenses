defmodule MyExpensesWeb.Api.V1.Controllers.GainController do
  @moduledoc false

  use MyExpensesWeb, :controller

  import Phoenix.Controller

  alias MyExpenses.Gains

  action_fallback MyExpensesWeb.Api.FallbackController

  def index_gain_categories(conn, _params) do
    gain_categories = Gains.list_gain_categories()

    json(conn, gain_categories, 200)
  end

  def get_gain_category(conn, %{"id" => gain_category_id}) do
    gain = Gains.get_gain_category(gain_category_id)

    json(conn, gain, 200)
  end

  def create_gain_category(conn, %{"gain_category" => gain_category_params}) do
    case Gains.create_gain_category(gain_category_params) do
      {:ok, gain_category} -> json(conn, gain_category, 201)
      error -> error
    end
  end

  def update_gain_category(conn, %{"id" => gain_category_id, "gain_category" => gain_category_params}) do
    gain_category = Gains.get_gain_category(gain_category_id)

    case Gains.update_gain_category(gain_category, gain_category_params) do
      {:ok, gain_category} -> json(conn, gain_category, 200)
      error -> error
    end
  end

  def delete_gain_category(conn, %{"id" => gain_category_id}) do
    gain_category = Gains.get_gain_category(gain_category_id)

    case Gains.delete_gain_category(gain_category) do
      {:ok, gain_category} -> json(conn, gain_category, 204)
      error -> error
    end
  end

  def index_gains(conn, _params) do
    user_id = get_user_id_by_conn(conn)
    gains = Gains.list_gains_by(%{user_id: user_id})

    json(conn, gains, 200)
  end

  def show_gain(conn, %{"id" => gain_id}) do
    user_id = get_user_id_by_conn(conn)

    gain = Gains.get_gain_by(%{user_id: user_id, id: gain_id})

    json(conn, gain, 200)
  end

  def create_gain(conn, %{"gain" => gain_params}) do
    case Gains.create_gain(gain_params) do
      {:ok, gain} -> json(conn, gain, 201)
      error -> error
    end
  end

  def update_gain(conn, %{"id" => gain_id, "gain" => gain_params}) do
    user_id = get_user_id_by_conn(conn)

    gain = Gains.get_gain_by(%{user_id: user_id, id: gain_id})

    gain_params = Map.drop(gain_params, ["user_id"])

    case Gains.update_gain(gain, gain_params) do
      {:ok, gain} -> json(conn, gain, 200)
      error -> error
    end
  end

  def delete_gain(conn, %{"id" => gain_id}) do
    user_id = get_user_id_by_conn(conn)

    gain = Gains.get_gain_by(%{user_id: user_id, gain_id: gain_id})

    case Gains.delete_gain(gain) do
      {:ok, gain} -> json(conn, gain, 204)
      error -> error
    end
  end
end
