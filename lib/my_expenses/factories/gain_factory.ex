defmodule MyExpenses.Factories.GainFactory do
  defmacro __using__(_opts) do
    quote do
      alias MyExpenses.Gains.Schema

      def gain_category_factory do
        %Schema.GainCategory{
          name: sequence(:name, &"gain-#{&1}"),
          description: Faker.Dog.PtBr.characteristic(),
          icon: Faker.Avatar.image_url(),
          color: "#" <> Faker.Color.rgb_hex()
        }
      end

      def gain_factory do
        %Schema.Gain{
          description: Faker.Food.description(),
          amount: Decimal.new("10"),
          date_receipt: Timex.today(),
          fix?: false,
          account: insert(:account),
          user: insert(:user),
          gain_category: insert(:gain_category)
        }
      end
    end
  end
end
