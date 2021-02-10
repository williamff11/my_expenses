defmodule MyExpenses.Accounts.Types.TypeAccount do
  @moduledoc false

  use Ecto.Type

  def type, do: :string

  def cast(atom)
      when atom in [
             :corrente,
             :poupanca,
             :salario,
             :investimento
           ] do
    {:ok, atom}
  end

  def cast(_), do: :error

  def load("corrente"), do: {:ok, :corrente}
  def load("poupanca"), do: {:ok, :poupanca}
  def load("salario"), do: {:ok, :salario}
  def load("investimento"), do: {:ok, :investimento}

  def dump(:corrente), do: {:ok, "corrente"}
  def dump(:poupanca), do: {:ok, "poupanca"}
  def dump(:salario), do: {:ok, "salario"}
  def dump(:investimento), do: {:ok, "investimento"}
end
