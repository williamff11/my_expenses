defmodule MyExpenses.GainsTest do
  @moduledoc false

  use MyExpenses.Support.DataCase, async: true

  import MyExpenses.Support.Accounts
  import MyExpenses.Support.Gains
  import MyExpenses.Support.Users

  alias MyExpenses.Gains
  alias MyExpenses.Gains.Schema

  describe "list_gains_categories" do
    setup :setup_category_gain

    test "listagem das categoria de ganhos", context do
      %{category: category} = context

      assert [
               %Schema.GainCategory{} = gain_category
               | _
             ] = Gains.list_gains_category()

      assert gain_category.id == category.id
    end
  end

  describe "show_gain_category/1" do
    setup :setup_category_gain

    test "retorna a categoria passada via id", context do
      %{category: category} = context

      category_id = category.id

      assert %{
               id: ^category_id,
               name: _,
               description: _,
               icon: _,
               color: _
             } = Gains.show_gain_category(category_id)
    end

    test "retorna nil caso o id informado não exista" do
      refute Gains.show_gain_category(0)
    end
  end

  describe "create_gain_category/1" do
    test "cria um ganho conforme os parametros informado" do
      params = %{
        color: "#E80345",
        description: "Categoria destinada para ganhos referentes à salário",
        icon: "https://www.flaticon.com/br/icone-gratis/utensilios-de-restaurante_18500",
        name: "Proventos"
      }

      assert {:ok,
              %{
                id: _,
                color: _,
                description: _,
                icon: _,
                name: _
              }} = Gains.create_gain_category(params)
    end

    test "retorna erro caso o nome da categoria já exista" do
      params = %{
        color: "#E80345",
        description: "Categoria destinada para ganhos referentes à salário",
        icon: "https://www.flaticon.com/br/icone-gratis/utensilios-de-restaurante_18500",
        name: "Ações"
      }

      Gains.create_gain_category(params)

      params = %{
        color: "#E80345",
        description: "Categoria destinada para ganhos referentes à salário",
        icon: "https://www.flaticon.com/br/icone-gratis/utensilios-de-restaurante_18500",
        name: "Ações"
      }

      assert {:error, errors} = Gains.create_gain_category(params)

      assert errors_on(errors) == %{name: ["has already been taken"]}
    end
  end

  describe "update_gain_category/2" do
    setup :setup_category_gain

    test "atualiza uma categoria conforme os parametros informados", context do
      %{category: category} = context

      category_id = category.id

      update_params = %{
        name: "Freelancer"
      }

      assert {:ok,
              %{
                id: ^category_id,
                name: "Freelancer"
              }} = Gains.update_gain_category(category, update_params)
    end
  end

  describe "delete_gain_category" do
    setup :setup_category_gain

    test "deleta categoria informada como parametro", context do
      %{category: category} = context

      category_id = category.id

      {:ok, _} = Gains.delete_gain_category(category_id)

      refute Gains.show_gain_category(category_id)
    end
  end

  describe "list_gains_by/1" do
    setup :setup_gains

    test "lista todos os ganhos do usuario", context do
      %{user: user, account: account, gain: gain} = context

      another_account = create_account(user)

      another_gain = create_gain(user, %{account_id: another_account.id})

      user_id = user.id
      gain_id = gain.id
      account_id = account.id
      another_gain_id = another_gain.id
      another_account_id = another_account.id

      assert [
               %Schema.Gain{
                 id: ^gain_id,
                 description: _,
                 amount: _,
                 attachment: _,
                 tag: _,
                 note: _,
                 date_receipt: _,
                 fix: _,
                 frequency: _,
                 account_id: ^account_id,
                 user_id: ^user_id,
                 gain_category: %{}
               },
               %Schema.Gain{
                 id: ^another_gain_id,
                 description: _,
                 amount: _,
                 attachment: _,
                 tag: _,
                 note: _,
                 date_receipt: _,
                 fix: _,
                 frequency: _,
                 account_id: ^another_account_id,
                 user_id: ^user_id,
                 gain_category: %{}
               }
               | _
             ] = Gains.list_gains_by(%{user_id: user_id})
    end
  end

  describe "show_gain/1" do
    setup :setup_gains

    test "retorna o ganho conforme parametros informados", context do
      %{user: user, gain: gain} = context

      user_id = user.id
      gain_id = gain.id

      assert %Schema.Gain{
               id: ^gain_id,
               user_id: ^user_id
             } = Gains.show_gain(gain_id)
    end

    test "nil caso o ganho não exita" do
      refute Gains.show_gain(Faker.UUID.v4())
    end
  end

  describe "create_gain/1" do
    setup :prepares_for_insert_gain

    test "cria e retorna o ganho conforme parametros informados", context do
      %{category: category, user: user, account: account} = context

      account_id = account.id
      user_id = user.id
      category_id = category.id

      params = %{
        description: "Salário mês de abril",
        amount: 8000,
        attachment: "comprovante.pdf",
        tag: "salario mensal",
        note: "mês abril",
        date_receipt: ~D[2021-04-11],
        fix: false,
        account_id: account_id,
        user_id: user_id
      }

      amount = Decimal.new("8000")

      assert {:ok,
              %{
                amount: ^amount,
                fix: false,
                account_id: ^account_id,
                user_id: ^user_id,
                gain_category_id: ^category_id
              }} = Gains.create_gain(category, params)
    end

    test "erro ao passar os parametros errados" do
    end
  end

  defp setup_category_gain(_) do
    %{category: create_gain_category()}
  end

  defp setup_gains(_) do
    user = create_user()

    account = create_account(user)

    gain = create_gain(user, %{account_id: account.id})

    %{user: user, account: account, gain: gain}
  end

  defp prepares_for_insert_gain(_) do
    user = create_user()

    category = create_gain_category()

    account = create_account(user)

    %{user: user, category: category, account: account}
  end
end
