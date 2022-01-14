defmodule MyExpenses.Factories do
  @moduledoc """
  Factory Generator.
  """
  use ExMachina.Ecto, repo: MyExpenses.Repo
  use MyExpenses.Factories.AccountFactory
  use MyExpenses.Factories.ExpenseFactory
  use MyExpenses.Factories.GainFactory
  use MyExpenses.Factories.UserFactory
end
