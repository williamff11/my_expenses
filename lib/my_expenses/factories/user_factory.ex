defmodule MyExpenses.Factories.UserFactory do
  defmacro __using__(_opts) do
    quote do
      alias MyExpenses.Users.Schema

      def user_factory do
        %Schema.User{
          name: Faker.StarWars.character(),
          email: sequence(:email, &"me-#{&1}@foo.com"),
          phone: "+55" <> String.pad_leading("#{:random.uniform(99_999_999_999)}", 11, "0"),
          birth_date: Faker.Date.date_of_birth(16..60),
          cpf: Brcpfcnpj.cnpj_generate(),
          login: String.downcase(Faker.Person.first_name()),
          password: "123456"
        }
      end
    end
  end
end
