defmodule MyExpenses.Support.Debts do
  @moduledoc """
  Support do contexto de dívidas
  """

  alias MyExpenses.Debts.Schema

  @doc """
  Cria uma categoria de dívidas
  """
  def create_category_debts(params \\ %{}) do
    default_params = %{
      name: Faker.Cannabis.category(),
      description: Faker.Dog.PtBr.characteristic(),
      icon: Faker.Avatar.image_url(),
      color: "#" <> Faker.Color.rgb_hex()
    }

    params = Enum.into(params, default_params)

    Schema.CategoryDebts
    |> struct!(params)
    |> MyExpenses.Repo.insert!()
  end

  @doc """
  Cria uma dívida associada ao usuário passado como parâmetro
  """
  def create_debt(user, params \\ %{}) do
    category = create_category_debts()

    default_params = %{
      description: Faker.Food.description(),
      amount: Faker.Commerce.price(),
      attachment: Faker.File.file_name(),
      tag: Enum.random(["work", "games", "locomotion", "car", "house", "music"]),
      note: Faker.Dog.PtBr.characteristic(),
      date_debt: Faker.Date.between(~D[2021-01-01], ~D[2022-12-25]),
      payed: Enum.random([true, false]),
      conta_id: Faker.UUID.v4(),
      user_id: user.id,
      category_debts_id: category.id
    }

    params = Enum.into(params, default_params)

    Schema.Debts
    |> struct!(params)
    |> MyExpenses.Repo.insert!()
    |> MyExpenses.Repo.preload([:category_debts])
  end
end
