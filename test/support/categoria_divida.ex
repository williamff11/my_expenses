defmodule MyExpenses.Support.CategoriaDivida do
  @moduledoc false

  alias MyExpenses.CategoriaDivida.Schema.CategoriaDivida

  def insert_categoria_dividas(params \\ %{}) do
    default_params = %{
      nome: Faker.StarWars.character(),
      descricao: Faker.StarWars.quote(),
      icon: Faker.Avatar.image_url(),
      color: "#" <> Faker.Color.rgb_hex()
    }

    params = Enum.into(params, default_params)

    CategoriaDivida
    |> struct!(params)
    |> MyExpenses.Repo.insert!()
  end
end
