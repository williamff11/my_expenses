defmodule MyExpenses.DebtsTest do
  @moduledoc false

  use MyExpenses.Support.DataCase, async: true

  import MyExpenses.Support.Debts
  import MyExpenses.Support.Users

  alias MyExpenses.Debts
  alias MyExpenses.Debts.Schema

  describe "list_debts_by/1" do
    setup :setup_debts

    test "lista todos as dívidas cadastradas por certo usuário", context do
      %{user: user, debt: debt} = context

      user_id = user.id

      assert [
               %Schema.Debts{
                 description: _,
                 amount: _,
                 attachment: _,
                 tag: _,
                 note: _,
                 date_debt: _,
                 payed: _,
                 conta_id: _,
                 user_id: user_id,
                 category_debts: %{}
               }
             ] = Debts.list_debts_by(%{user_id: user_id})
    end

    test "list as dívidas conformes parâmetros informados", context do
      %{user: user} = context

      debt = create_debt(user)

      category_debts_id = debt.category_debts.id

      user_id = user.id

      assert [
               %Schema.Debts{
                 description: _,
                 amount: _,
                 attachment: _,
                 tag: _,
                 note: _,
                 date_debt: _,
                 payed: _,
                 conta_id: _,
                 user_id: user_id,
                 category_debts: %{id: category_debts_id}
               }
             ] = Debts.list_debts_by(%{user_id: user_id, category_debts_id: category_debts_id})
    end

    test "lista nenhuma dívida caso o user_id de consulta seja diferente da dívida", context do
      %{user: user, debt: debt} = context

      user_id = user.id

      assert [
               %MyExpenses.Debts.Schema.Debts{user_id: user_id}
             ] = Debts.list_debts_by(%{user_id: user_id})

      another_user = create_user()

      another_user_id = another_user.id

      assert [] = Debts.list_debts_by(%{user_id: another_user_id})
    end

    test "erro ao tentar consultar as dívidas do usuário sem informar o user_id", context do
      %{debt: debt} = context

      category_debts_id = debt.category_debts.id

      assert catch_error(Debts.list_debts_by(%{category_debts_id: category_debts_id})) ==
               %RuntimeError{message: "key user_id is required"}
    end
  end

  describe "show_debts/2" do
    setup :setup_debts

    test "mostra todos os atributos de uma dívida", context do
      %{user: user, debt: debt} = context

      user_id = user.id

      category_debts_id = debt.category_debts.id

      assert %Schema.Debts{
               description: _,
               amount: _,
               attachment: _,
               tag: _,
               note: _,
               date_debt: _,
               payed: _,
               conta_id: _,
               user_id: user_id,
               category_debts: %{id: category_debts_id}
             } = Debts.show_debt(debt.id)
    end

    test "nil caso a dívida não exita" do
      refute Debts.show_debt(Faker.UUID.v4())
    end
  end

  describe "create_debts/1" do
    setup :setup_user
    setup :setup_categoty_debts

    setup do
      params = %{
        description: "description_test",
        amount: 8.88,
        attachment: "random.jpg",
        tag: "work",
        note: "note_test",
        date_debt: ~D[2021-01-26],
        payed: true,
        conta_id: "d6d98b88-c866-4496-9bd4-de7ba48d0f52"
      }

      %{debts_params: params}
    end

    test "cria a dívida conforme os parâmetros informados", context do
      %{user: user, category: category, debts_params: debts_params} = context

      user_id = user.id
      category_debts_id = category.id

      assert {:ok,
              %Schema.Debts{
                user_id: user_id,
                category_debts: %{id: category_debts_id}
              }} = Debts.create_debt(user, category, debts_params)
    end
  end

  defp setup_debts(_) do
    user = create_user()

    debt = create_debt(user)

    %{user: user, debt: debt}
  end

  defp setup_user(_) do
    %{user: create_user()}
  end

  defp setup_categoty_debts(_) do
    %{category: create_category_debts()}
  end
end
