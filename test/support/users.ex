defmodule MyExpenses.Support.Users do
  @moduledoc false

  alias MyExpenses.Users.Schema.User

  @spec create_user() :: User.t()
  def create_user(params \\ %{}) do
    default_params = %{
      name: Faker.StarWars.character(),
      email: Faker.Internet.email(),
      phone: String.replace(Faker.Phone.EnGb.mobile_number(), " ", ""),
      birth_date: Faker.Date.date_of_birth(16..60),
      cpf: Brcpfcnpj.cpf_generate(),
      login: String.downcase(Faker.Person.first_name()),
      password: "123456"
    }

    params = Enum.into(params, default_params)

    User
    |> struct!(params)
    |> MyExpenses.Repo.insert!()
  end
end
