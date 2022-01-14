defmodule MyExpenses.Factories.AccountFactory do
  defmacro __using__(_opts) do
    quote do
      alias MyExpenses.Accounts.Schema

      def institution_factory do
        %Schema.Institution{
          name: Faker.Person.PtBr.first_name(),
          legal_name: Faker.Person.PtBr.name(),
          logo: Faker.Avatar.image_url()
        }
      end

      def account_factory do
        %Schema.Account{
          name: Faker.Dog.PtBr.name(),
          num_account: sequence(:num_account, &"00000#{&1}-0"),
          initial_amount_value: Decimal.new("100"),
          type_account: :corrente,
          user: insert(:user),
          institution: insert(:institution)
        }
      end
    end
  end
end
