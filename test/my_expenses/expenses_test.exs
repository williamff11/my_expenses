defmodule MyExpenses.ExpensesTest do
  @moduledoc false

  use MyExpenses.Support.DataCase, async: true

  import MyExpenses.Support.Expenses
  import MyExpenses.Support.Users

  alias MyExpenses.Expenses
  alias MyExpenses.Expenses.Schema

  describe "list_expense_categorys" do
    setup :setup_categoty_expenses

    test "listagem das categorias de gastos", context do
      %{category: category} = context

      category_id = category.id

      assert [
               %Schema.ExpenseCategory{
                 id: category_id,
                 name: _,
                 description: _,
                 icon: _,
                 color: _
               }
             ] = Expenses.list_expense_category()
    end

    @tag :skip
    test "lista somente as categorias onde o usuário possui gastos" do
      :not_implemeted
    end
  end

  describe "show_expense_category" do
    setup :setup_categoty_expenses

    test "retorna nil ao passar uma categoria que não existe" do
      refute Expenses.show_expense_category(0)
    end

    test "mostra determinada categoria de gastos, filtrando por id", context do
      %{category: category} = context

      category_id = category.id

      assert %Schema.ExpenseCategory{
               id: category_id,
               name: _,
               description: _,
               icon: _,
               color: _
             } = Expenses.show_expense_category(category_id)
    end
  end

  describe "create_expense_category" do
    test "retorna erro ao tentar criar uma categoria com os parâmetros inválidos" do
      params = %{
        color: "#E80345",
        description: "Categoria destinada para gastos em restaurantes e deliverys de comida",
        icon: "https://www.flaticon.com/br/icone-gratis/utensilios-de-restaurante_18500",
        name: ""
      }

      assert {:error, errors} = Expenses.create_expense_category(params)

      assert errors = [name: {"can't be blank", [validation: :required]}]
    end

    test "cria categoria conforme parametros passados" do
      params = %{
        color: "#FFF",
        description: "Categoria destinada para gastos em restaurantes e deliverys de comida",
        icon: "https://www.flaticon.com/br/icone-gratis/utensilios-de-restaurante_18500",
        name: "Alimentação"
      }

      category = Expenses.create_expense_category(params)

      assert {:ok,
              %Schema.ExpenseCategory{
                id: _,
                color: _,
                description: _,
                icon: _,
                name: "Alimentação"
              }} = category
    end
  end

  describe "update_expense_category" do
    setup :setup_categoty_expenses

    test "edita a categoria conforme os dados passados", context do
      %{category: category} = context

      category_id = category.id

      params_update = %{color: "#6bc5d2", description: "description"}

      assert {:ok,
              %Schema.ExpenseCategory{
                id: category_id,
                name: _,
                description: "description",
                icon: _,
                color: "#6bc5d2"
              }} = Expenses.update_expense_category(category, params_update)
    end

    test "erro ao tentar editar categoria com os parâmetros inválidos", context do
      %{category: category} = context

      category_id = category.id

      params_update = %{color: "#6bc5d2", name: "ar"}

      assert {:error, errors} = Expenses.update_expense_category(category, params_update)

      assert errors = [
               name:
                 {"should be at least %{count} character(s)",
                  [count: 3, validation: :length, kind: :min, type: :string]}
             ]
    end
  end

  describe "delete_expense_category" do
    setup :setup_categoty_expenses

    test "deleta a categoria passada", context do
      %{category: category} = context

      category_id = category.id

      Expenses.delete_expense_category(category_id)

      refute Expenses.show_expense_category(category_id)
    end
  end

  describe "list_expenses_by/1" do
    setup :setup_expenses

    test "lista todas os gastos cadastradas por certo usuário", context do
      %{user: user, expense: expense} = context

      user_id = user.id

      assert [
               %Schema.Expense{
                 description: _,
                 amount: _,
                 attachment: _,
                 tag: _,
                 note: _,
                 date_spend: _,
                 payed: _,
                 fix: _,
                 frequency: _,
                 conta_id: _,
                 user_id: user_id,
                 expense_category: %{}
               }
             ] = Expenses.list_expenses_by(%{user_id: user_id})
    end

    test "lista todas os gastos que são fixos", context do
      %{user: user} = context

      create_expense(user, %{fix: true, frequency: :mensalmente})

      assert [
               %Schema.Expense{
                 fix: true,
                 frequency: frequency,
                 expense_category: %{}
               }
               | _
             ] = Expenses.list_expenses_fixed()

      assert frequency
    end

    test "lista os gastos conformes parâmetros informados", context do
      %{user: user} = context

      expense = create_expense(user)

      expense_category_id = expense.expense_category.id

      user_id = user.id

      assert [
               %Schema.Expense{
                 description: _,
                 amount: _,
                 attachment: _,
                 tag: _,
                 note: _,
                 date_spend: _,
                 payed: _,
                 fix: _,
                 frequency: _,
                 conta_id: _,
                 user_id: user_id,
                 expense_category: %{id: expense_category_id}
               }
               | _
             ] =
               Expenses.list_expenses_by(%{
                 user_id: user_id,
                 expense_category_id: expense_category_id
               })
    end

    test "lista nenhum gasto caso o user_id de consulta seja diferente do gasto", context do
      %{user: user, expense: expense} = context

      user_id = user.id

      assert [
               %MyExpenses.Expenses.Schema.Expense{user_id: user_id}
             ] = Expenses.list_expenses_by(%{user_id: user_id})

      another_user = create_user()

      another_user_id = another_user.id

      assert [] = Expenses.list_expenses_by(%{user_id: another_user_id})
    end

    test "erro ao tentar consultar os gastos do usuário sem informar o user_id", context do
      %{expense: expense} = context

      expense_category_id = expense.expense_category.id

      assert catch_error(Expenses.list_expenses_by(%{expense_category_id: expense_category_id})) ==
               %RuntimeError{message: "key user_id is required"}
    end
  end

  describe "show_expenses/2" do
    setup :setup_expenses

    test "mostra todos os atributos de um gasto", context do
      %{user: user, expense: expense} = context

      user_id = user.id

      expense_category_id = expense.expense_category.id

      assert %Schema.Expense{
               description: _,
               amount: _,
               attachment: _,
               tag: _,
               note: _,
               date_spend: _,
               payed: _,
               fix: _,
               frequency: _,
               conta_id: _,
               user_id: user_id,
               expense_category: %{id: expense_category_id}
             } = Expenses.show_expense(expense.id)
    end

    test "nil caso o gasto não exita" do
      refute Expenses.show_expense(Faker.UUID.v4())
    end
  end

  describe "create_expenses/1" do
    setup :setup_user
    setup :setup_categoty_expenses

    test "cria um gasto conforme os parâmetros informados", context do
      %{user: user, category: category} = context

      user_id = user.id

      params = %{
        description: "description_test",
        amount: 8.88,
        attachment: "random.jpg",
        tag: "work",
        note: "note_test",
        date_spend: ~D[2021-01-26],
        payed: true,
        fix: false,
        conta_id: "d6d98b88-c866-4496-9bd4-de7ba48d0f52",
        user_id: user_id
      }

      expense_category_id = category.id

      assert {:ok,
              %Schema.Expense{
                payed: true,
                fix: false,
                conta_id: _,
                user_id: user_id
              }} = Expenses.create_expense(category, params)
    end

    test "cria um gasto somente com os dados básicos", context do
      %{user: user, category: category} = context

      user_id = user.id

      params = %{
        description: "a",
        amount: 1,
        date_spend: ~D[2021-01-26],
        payed: true,
        fix: false,
        conta_id: "d6d98b88-c866-4496-9bd4-de7ba48d0f52",
        user_id: user_id
      }

      expense_category_id = category.id

      assert {:ok,
              %Schema.Expense{
                payed: true,
                fix: false,
                conta_id: _,
                user_id: user_id
              }} = Expenses.create_expense(category, params)
    end

    test "retorna erro ao passar parametros errados na criação de um gasto", context do
      %{category: category} = context

      params = %{
        amount: 0,
        date_spend: ~D[2021-01-26],
        payed: nil,
        fix: nil,
        user_id: 0
      }

      expense_category_id = category.id

      assert {:error, %Ecto.Changeset{errors: errors}} = Expenses.create_expense(category, params)

      assert errors:
               [
                 amount: {"must be greater than %{number}", _},
                 description: {"can't be blank", [validation: :required]},
                 payed: {"can't be blank", [validation: :required]},
                 fix: {"can't be blank", [validation: :required]},
                 conta_id: {"can't be blank", [validation: :required]},
                 user_id: {"is invalid", [type: :binary_id, validation: :cast]}
               ] = errors
    end
  end

  defp setup_expenses(_) do
    user = create_user()

    expense = create_expense(user)

    %{user: user, expense: expense}
  end

  defp setup_user(_) do
    %{user: create_user()}
  end

  defp setup_categoty_expenses(_) do
    %{category: create_expense_category()}
  end
end
