defmodule MyExpenses.Support.Debts do
  @moduledoc false

  alias MyExpenses.Debts.Schema

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

  def create_debt(params \\ %{}) do
    category = create_category_debts()

    IO.inspect(category)

    default_params = %{
      description: Faker.Food.description(),
      amount: Faker.Commerce.price(),
      attachment: Faker.File.file_name(),
      tag: Enum.random(["work", "games", "locomotion", "car", "house", "music"]),
      note: Faker.Dog.PtBr.characteristic(),
      date_debt: Faker.Date.between(~D[2021-01-01], ~D[2022-12-25]),
      payed: Enum.random([true, false]),
      conta_id: Faker.UUID.v4(),
      user_id: Faker.UUID.v4(),
      category_debts_id: category
    }

    params = Enum.into(params, default_params)

    Schema.Debts
    |> struct!(params)
    |> MyExpenses.Repo.insert!()
    |> MyExpenses.Repo.preload([:category_debts])
  end
end
