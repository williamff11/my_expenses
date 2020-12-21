defmodule MyExpenses.Support.Debts do
  @moduledoc false

  alias MyExpenses.Debts.Schema

  def create_category_debts(params \\ %{}) do
    default_params = %{
      name: Faker.StarWars.character(),
      description: Faker.StarWars.quote(),
      icon: Faker.Avatar.image_url(),
      color: "#" <> Faker.Color.rgb_hex()
    }

    params = Enum.into(params, default_params)

    Schema.CategoryDebts
    |> struct!(params)
    |> MyExpenses.Repo.insert!()
  end
end
