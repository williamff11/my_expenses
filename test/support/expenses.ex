defmodule MyExpenses.Support.Expenses do
  @moduledoc """
  Support do contexto de gasto.
  """

  alias MyExpenses.Expenses.Schema

  @doc """
  Cria uma categoria de gasto.
  """
  def create_expense_category(params \\ %{}) do
    default_params = %{
      name: Faker.Cannabis.category(),
      description: Faker.Dog.PtBr.characteristic(),
      icon: Faker.Avatar.image_url(),
      color: "#" <> Faker.Color.rgb_hex()
    }

    params = Enum.into(params, default_params)

    Schema.ExpenseCategory
    |> struct!(params)
    |> MyExpenses.Repo.insert!()
  end

  @doc """
  Cria um gasto associado ao usuário passado como parâmetro.
  """
  def create_expense(user, params \\ %{}) do
    category = create_expense_category()

    boolean_fix = Enum.random([true, false])

    frequency =
      if boolean_fix,
        do: Enum.random([:semanalmente, :quinzenalmente, :mensalmente, :anualmente]),
        else: nil

    default_params = %{
      description: Faker.Food.description(),
      amount: Faker.Commerce.price(),
      attachment: Faker.File.file_name(),
      tag: Enum.random(["launch work", "date with my girlfriend", "beer", "house", "music"]),
      note: Faker.Dog.PtBr.characteristic(),
      date_spend: Faker.Date.between(~D[2021-01-01], ~D[2022-12-25]),
      payed: Enum.random([true, false]),
      fix: boolean_fix,
      frequency: frequency,
      conta_id: Faker.UUID.v4(),
      user_id: user.id,
      expense_category_id: category.id
    }

    params = Map.merge(default_params, params)

    Schema.Expense
    |> struct!(params)
    |> MyExpenses.Repo.insert!()
    |> MyExpenses.Repo.preload(:expense_category)
  end
end
