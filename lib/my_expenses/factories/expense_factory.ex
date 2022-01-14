defmodule MyExpenses.Factories.ExpenseFactory do
  defmacro __using__(_opts) do
    quote do
      alias MyExpenses.Expenses.Schema

      def expense_category_factory do
        %Schema.ExpenseCategory{
          name: Faker.Cannabis.category(),
          description: Faker.Dog.PtBr.characteristic(),
          icon: Faker.Avatar.image_url(),
          color: "#" <> Faker.Color.rgb_hex()
        }
      end

      def expense_factory do
        %Schema.Expense{
          description: Faker.Food.description(),
          amount: Decimal.new("10"),
          date_spend: Timex.today(),
          payed?: true,
          payment_method: :pix,
          fix?: false,
          account: insert(:account),
          user: insert(:user),
          expense_category: insert(:expense_category)
        }
      end
    end
  end
end
