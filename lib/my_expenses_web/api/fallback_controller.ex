defmodule MyExpensesWeb.Api.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """

  use MyExpensesWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(traverse_errors(changeset), 422)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> json()
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> json()
  end

  def call(conn, {:error, error}) when is_map(error) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{"errors" => error})
  end

  def call(conn, {:error, error}) do
    conn
    |> put_status(:bad_request)
    |> json(%{"errors" => error})
  end
end
