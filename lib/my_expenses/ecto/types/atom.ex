defmodule MyExpenses.Ecto.Types.Atom do
  @moduledoc """
  Transforma um atom em uma string.

  Útil para columns do tipo string mas que no sistema são utilizadas como atom.
  """

  use Ecto.Type

  def type, do: :string

  def cast(value) when is_binary(value) do
    {:ok, String.to_existing_atom(value)}
  end

  def cast(value) when is_atom(value) do
    {:ok, value}
  end

  def cast(_), do: :error

  def load(str) when is_binary(str) do
    {:ok, String.to_existing_atom(str)}
  end

  def dump(atom) when is_atom(atom) do
    {:ok, to_string(atom)}
  end

  def dump(_), do: :error
end
