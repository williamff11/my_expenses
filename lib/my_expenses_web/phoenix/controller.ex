defmodule MyExpensesWeb.Phoenix.Controller do
  @moduledoc """
  Módule for controller extension, adding some helper functions.
  """

  import Phoenix.Controller
  import Plug.Conn

  @doc """
  Adds the result ate JSON with the given status code.
  """
  def json(conn), do: json(conn)

  def json(conn, data, status_code) do
    conn
    |> put_status(status_code)
    |> json(data)
  end

  @doc """
  Format a changeset to return of API.
  """
  def traverse_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  @doc """
  Format a string map to a atom map.
  """
  def transform_keys_to_atoms(params) do
    params
    |> Enum.map(fn {key, value} -> {String.to_existing_atom(key), value} end)
    |> Enum.into(%{})
  end
end
