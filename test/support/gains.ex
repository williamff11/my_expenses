defmodule MyExpenses.Support.Gains do
  @moduledoc """
    Support do contexto de lucros.
  """

  alias MyExpenses.Gains.Schema

  @doc """
  Cria uma categoria de ganho
  """
  def create_gain_category(params \\ %{}) do
    default_params = %{
      name: Faker.Cannabis.category(),
      description: Faker.Dog.PtBr.characteristic(),
      icon: Faker.Avatar.image_url(),
      color: "#" <> Faker.Color.rgb_hex()
    }

    params = Enum.into(params, default_params)

    Schema.GainCategory
    |> struct!(params)
    |> MyExpenses.Repo.insert!()
  end

  def create_gain(user, params \\ %{}, category \\ %{}) do
    category =
      case category do
        %Schema.GainCategory{} -> category
        %{} -> create_gain_category()
      end

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
      date_receipt: Faker.Date.between(~D[2021-01-01], ~D[2022-12-25]),
      fix: boolean_fix,
      frequency: frequency,
      account_id: Faker.UUID.v4(),
      user_id: user.id,
      gain_category_id: category.id
    }

    params = Map.merge(default_params, params)

    Schema.Gain
    |> struct!(params)
    |> MyExpenses.Repo.insert!()
    |> MyExpenses.Repo.preload(:gain_category)
  end
end
