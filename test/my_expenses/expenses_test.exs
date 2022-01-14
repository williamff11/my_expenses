defmodule MyExpenses.ExpensesTest do
  @moduledoc false

  use MyExpenses.Support.DataCase, async: true

  import MyExpenses.Factories

  alias MyExpenses.Expenses
  alias MyExpenses.Expenses.Schema

  describe "list_expense_categorys" do
    setup :setup_category_expenses

    test "listagem das categorias de gastos", context do
      %{category: category} = context

      category_id = category.id

      assert [
               %Schema.ExpenseCategory{
                 id: ^category_id,
                 name: _,
                 description: _,
                 icon: _,
                 color: _
               }
             ] = Expenses.list_expense_category()
    end
  end

  describe "show_expense_category" do
    setup :setup_category_expenses

    test "retorna nil ao passar uma categoria que não existe" do
      refute Expenses.show_expense_category(Faker.UUID.v4())
    end

    test "mostra determinada categoria de gastos, filtrando por id", context do
      %{category: category} = context

      category_id = category.id

      assert %Schema.ExpenseCategory{
               id: ^category_id,
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

      assert errors_on(errors) == %{name: ["can't be blank"]}
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
    setup :setup_category_expenses

    test "edita a categoria conforme os dados passados", context do
      %{category: category} = context

      category_id = category.id

      params_update = %{color: "#6bc5d2", description: "description"}

      assert {:ok,
              %Schema.ExpenseCategory{
                id: ^category_id,
                name: _,
                description: "description",
                icon: _,
                color: "#6bc5d2"
              }} = Expenses.update_expense_category(category, params_update)
    end

    test "erro ao tentar editar categoria com os parâmetros inválidos", context do
      %{category: category} = context

      params_update = %{color: "#6bc5d2", name: "ar"}

      assert {:error, errors} = Expenses.update_expense_category(category, params_update)

      assert errors_on(errors) == %{
               name: ["should be at least 3 character(s)"]
             }
    end
  end

  describe "delete_expense_category" do
    setup :setup_category_expenses

    test "deleta a categoria passada", context do
      %{category: category} = context

      category_id = category.id

      assert {
               :ok,
               %Schema.ExpenseCategory{id: ^category_id}
             } = Expenses.delete_expense_category(category_id)

      refute Expenses.show_expense_category(category_id)
    end
  end

  describe "list_expenses_by/1" do
    setup :setup_expenses

    test "lista todas os gastos cadastradas por certo usuário", context do
      %{user: user, account: account} = context

      user_id = user.id
      account_id = account.id

      assert [
               %Schema.Expense{
                 description: _,
                 amount: _,
                 attachment: _,
                 tag: _,
                 note: _,
                 date_spend: _,
                 payed?: _,
                 fix?: _,
                 frequency: _,
                 account_id: ^account_id,
                 user_id: ^user_id,
                 expense_category: %{}
               }
             ] = Expenses.list_expenses_by(%{user_id: user_id, account_id: account_id})
    end

    test "lista os gastos conformes parâmetros informados", context do
      %{user: user, expense: expense} = context

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
                 payed?: _,
                 fix?: _,
                 frequency: _,
                 account_id: _,
                 user_id: ^user_id,
                 expense_category: %{id: ^expense_category_id}
               }
               | _
             ] =
               Expenses.list_expenses_by(%{
                 user_id: user_id,
                 expense_category_id: expense_category_id
               })
    end

    test "lista nenhum gasto caso o user_id de consulta seja diferente do gasto", context do
      %{user: user} = context

      user_id = user.id

      assert [
               %MyExpenses.Expenses.Schema.Expense{user_id: ^user_id}
             ] = Expenses.list_expenses_by(%{user_id: user_id})

      another_user = insert(:user)

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

  describe "list_expenses_fixed_by/1" do
    setup :setup_expenses_fixed

    test "lista todos os gastos cadastrados que são fixos", context do
      %{user: user} = context

      insert(:expense, user: user, fix?: true, frequency: :mensalmente)

      assert [
               %Schema.Expense{
                 fix?: true,
                 frequency: :mensalmente,
                 expense_category: %{}
               }
               | _
             ] = Expenses.list_expenses_fixed_by()
    end

    test "lista todos os gastos fixos do usuário", context do
      %{user: user, account: account} = context

      user_id = user.id
      account_id = account.id

      insert(:expense, user: user, fix?: true, account: account, frequency: :mensalmente)

      another_account = insert(:account, user: user)
      another_account_id = another_account.id

      insert(:expense, user: user, fix?: true, account: another_account, frequency: :semanalmente)

      assert [
               %Schema.Expense{
                 fix?: true,
                 frequency: _,
                 account_id: ^account_id,
                 user_id: ^user_id,
                 expense_category: %{}
               },
               %Schema.Expense{
                 fix?: true,
                 frequency: _,
                 account_id: ^another_account_id,
                 user_id: ^user_id,
                 expense_category: %{}
               }
               | _
             ] = Expenses.list_expenses_fixed_by(%{user_id: user_id})
    end

    test "lista todos os gastos fixos por conta do usuário", context do
      %{user: user, account: account} = context

      user_id = user.id
      account_id = account.id

      insert(:expense, user: user, fix?: true, account: account, frequency: :mensalmente)

      another_account = insert(:account, user: user)
      another_account_id = another_account.id

      insert(:expense, user: user, fix?: true, account: another_account, frequency: :semanalmente)

      assert [
               %Schema.Expense{
                 fix?: true,
                 frequency: :mensalmente,
                 account_id: ^account_id,
                 user_id: ^user_id,
                 expense_category: %{}
               }
             ] =
               Expenses.list_expenses_fixed_by(%{
                 user_id: user_id,
                 account_id: account_id,
                 fix?: true
               })

      assert [
               %Schema.Expense{
                 fix?: true,
                 frequency: :semanalmente,
                 account_id: ^another_account_id,
                 user_id: ^user_id,
                 expense_category: %{}
               }
             ] =
               Expenses.list_expenses_fixed_by(%{
                 user_id: user_id,
                 account_id: another_account_id,
                 fix?: true
               })
    end

    test "lista todos os gastos fixos que correspondem à frequência informada", context do
      %{user: user, account: account} = context

      user_id = user.id
      account_id = account.id

      insert(:expense, user: user, fix?: true, account: account, frequency: :mensalmente)

      assert [
               %Schema.Expense{
                 fix?: true,
                 frequency: :mensalmente,
                 account_id: ^account_id,
                 user_id: ^user_id,
                 expense_category: %{}
               }
             ] =
               Expenses.list_expenses_fixed_by(%{
                 user_id: user_id,
                 frequency: :mensalmente,
                 fix?: true
               })
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
               payed?: _,
               fix?: _,
               frequency: _,
               account_id: _,
               user_id: ^user_id,
               expense_category: %{id: ^expense_category_id}
             } = Expenses.show_expense(expense.id)
    end

    test "nil caso o gasto não exita" do
      refute Expenses.show_expense(Faker.UUID.v4())
    end
  end

  describe "create_expense/2" do
    setup :setup_account
    setup :setup_category_expenses

    test "cria um gasto conforme os parâmetros informados", context do
      %{account: account, category: category, user: user} = context

      account_id = account.id
      user_id = user.id

      params = params_for(:expense, account: account, user: user)

      assert {:ok,
              %Schema.Expense{
                payed?: true,
                fix?: false,
                account_id: ^account_id,
                user_id: ^user_id
              }} = Expenses.create_expense(category, params)
    end

    test "cria um gasto somente com os dados básicos", context do
      %{account: account, category: category, user: user} = context

      account_id = account.id
      user_id = user.id

      params = params_for(:expense, account: account, user: user)

      assert {:ok,
              %Schema.Expense{
                payed?: true,
                fix?: false,
                account_id: ^account_id,
                user_id: ^user_id
              }} = Expenses.create_expense(category, params)
    end

    test "retorna erro ao passar parametros errados na criação de um gasto", context do
      %{category: category} = context

      params = %{
        amount: 0,
        date_spend: ~D[2021-01-26],
        payed?: nil,
        fix?: nil,
        user_id: 0
      }

      assert {:error, %Ecto.Changeset{errors: errors}} = Expenses.create_expense(category, params)

      assert errors:
               [
                 amount: {"must be greater than %{number}", _},
                 description: {"can't be blank", [validation: :required]},
                 payed?: {"can't be blank", [validation: :required]},
                 payment_method: {"can't be blank", [validation: :required]},
                 fix?: {"can't be blank", [validation: :required]},
                 account_id: {"can't be blank", [validation: :required]},
                 user_id: {"is invalid", [type: :binary_id, validation: :cast]}
               ] = errors
    end
  end

  describe "update_expense/2" do
    setup :setup_expenses

    test "realiza um update na conta conforme os parâmetros", context do
      %{expense: expense, user: user} = context

      expense_id = expense.id
      user_id = user.id

      params = %{
        date_spend: ~D[2019-09-20],
        tag: "shoes"
      }

      assert {:ok,
              %Schema.Expense{
                id: ^expense_id,
                date_spend: ~D[2019-09-20],
                tag: "shoes",
                user_id: ^user_id
              }} = Expenses.update_expense(expense, params)
    end

    test "realiza um update trocando a conta do gasto", context do
      %{expense: expense, user: user} = context

      another_account_id = insert(:account, user: user).id
      expense_id = expense.id
      user_id = user.id

      params = %{
        account_id: another_account_id
      }

      assert {:ok,
              %Schema.Expense{
                id: ^expense_id,
                account_id: ^another_account_id,
                user_id: ^user_id
              }} = Expenses.update_expense(expense, params)
    end

    test "erro ao tentar raelizar update com os parâmtros inválidos", context do
      %{expense: expense} = context

      params = %{
        amount: 0,
        date_spend: ~D[2021-01-26],
        payed?: nil,
        fix?: nil,
        account_id: 0
      }

      assert {:error, %Ecto.Changeset{errors: errors}} = Expenses.update_expense(expense, params)

      assert errors:
               [
                 amount: {"must be greater than %{number}", _},
                 payed?: {"can't be blank", [validation: :required]},
                 fix?: {"can't be blank", [validation: :required]},
                 account_id: {"is invalid", [type: :binary_id, validation: :cast]}
               ] = errors
    end
  end

  describe "list_expense_category_by_user/1" do
    setup :create_many_expenses

    test "lista somente as categoria de gastos do usuário", context do
      %{user: user} = context

      expenses_categories = Expenses.list_expense_category_by_user(user)

      assert [
               %Schema.ExpenseCategory{}
               | _
             ] = expenses_categories
    end
  end

  describe "delete_expense/2" do
    setup :setup_expenses

    test "deleta de forma lógica o gasto", context do
      %{expense: expense} = context

      expense_id = expense.id
      assert {:ok, %Schema.Expense{id: ^expense_id}} = Expenses.delete_expense(expense)

      refute Expenses.show_expense(expense_id)
    end
  end

  def setup_account(_) do
    user = insert(:user)

    account = insert(:account, user: user)

    %{user: user, account: account}
  end

  defp setup_categoty_expenses(_) do
    %{category: insert(:expense_category)}
  end

  defp setup_expenses(_) do
    user = insert(:user)

    account = insert(:account, user: user)
    expense = insert(:expense, user: user, account: account)

    %{user: user, account: account, expense: expense}
  end

  defp setup_expenses_fixed(_) do
    user = insert(:user)

    account = insert(:account, user: user)

    %{user: user, account: account}
  end

  defp create_many_expenses(_) do
    %{user: user, account: account, expense: expense} = setup_expenses([])

    another_account = insert(:account, user: user)

    account_of_expense = Enum.random([account, another_account])

    expense_category = expense.expense_category

    insert_list(7, :expense, user: user, account: account_of_expense, expense_category: expense_category)

    %{user: user, account: account, expense: expense}
  end
end
