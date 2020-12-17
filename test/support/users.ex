defmodule MyExpenses.Support.Users do
  @moduledoc false

  alias MyExpenses.Users.Schema.User

  @spec insert_user() :: User.t()
  def insert_user(params \\ %{}) do
    default_params = %{
      name: Faker.StarWars.character(),
      email: Faker.Internet.email(),
      phone: Faker.Phone.EnGb.mobile_number() |> String.replace(" ", ""),
      birth_date: Faker.Date.date_of_birth(16..60),
      cpf: Brcpfcnpj.cnpj_generate(),
      login: Faker.Person.first_name() |> String.downcase(),
      password: "123456"
    }

    params = Enum.into(params, default_params)

    User
    |> struct!(params)
    |> MyExpenses.Repo.insert!()
  end
end
