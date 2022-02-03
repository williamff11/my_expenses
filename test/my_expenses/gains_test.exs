defmodule MyExpenses.GainsTest do
  @moduledoc false

  use MyExpenses.Support.DataCase, async: true

  import MyExpenses.Factories

  alias MyExpenses.Gains
  alias MyExpenses.Gains.Schema

  describe "list_gains_categories" do
    setup :setup_category_gain

    test "listagem das categoria de ganhos", context do
      %{category: category} = context

      assert [
               %Schema.GainCategory{} = gain_category
               | _
             ] = Gains.list_gain_categories()

      assert gain_category.id == category.id
    end
  end

  describe "get_gain_category/1" do
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
             } = Gains.get_gain_category(category_id)
    end

    test "retorna nil caso o id informado não exista" do
      refute Gains.get_gain_category(Faker.UUID.v4())
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

      {:ok, _} = Gains.delete_gain_category(category)

      refute Gains.get_gain_category(category_id)
    end
  end

  describe "list_gains_by/1" do
    setup :setup_gains

    test "lista todos os ganhos do usuario", context do
      %{user: user, account: account, gain: gain} = context

      another_account = insert(:account, user: user)

      another_gain = insert(:gain, user: user, account: another_account)

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
                 fix?: _,
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
                 fix?: _,
                 frequency: _,
                 account_id: ^another_account_id,
                 user_id: ^user_id,
                 gain_category: %{}
               }
               | _
             ] = Gains.list_gains_by(%{user_id: user_id})
    end
  end

  describe "get_gain/1" do
    setup :setup_gains

    test "retorna o ganho conforme parametros informados", context do
      %{user: user, gain: gain} = context

      user_id = user.id
      gain_id = gain.id

      assert %Schema.Gain{
               id: ^gain_id,
               user_id: ^user_id
             } = Gains.get_gain(gain_id)
    end

    test "nil caso o ganho não exita" do
      refute Gains.get_gain(Faker.UUID.v4())
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
        fix?: false,
        account_id: account_id,
        user_id: user_id,
        gain_category_id: category_id
      }

      amount = Decimal.new("8000")

      assert {:ok,
              %{
                amount: ^amount,
                fix?: false,
                account_id: ^account_id,
                user_id: ^user_id,
                gain_category_id: ^category_id
              }} = Gains.create_gain(params)
    end

    test "erro ao passar os parametros errados" do
    end
  end

  describe "update_gain/2" do
    setup :setup_gains

    test "realiza um update no gain conforme os parâmetros", context do
      %{gain: gain, user: user} = context

      gain_id = gain.id
      user_id = user.id

      params = %{
        date_receipt: ~D[2019-09-20],
        description: "side_job"
      }

      assert {:ok,
              %Schema.Gain{
                id: ^gain_id,
                date_receipt: ~D[2019-09-20],
                description: "side_job",
                user_id: ^user_id
              }} = Gains.update_gain(gain, params)
    end

    test "realiza um update trocando a conta do recebimento", context do
      %{gain: gain, user: user} = context

      another_account_id = insert(:account, user: user).id
      gain_id = gain.id
      user_id = user.id

      params = %{
        account_id: another_account_id
      }

      assert {:ok,
              %Schema.Gain{
                id: ^gain_id,
                account_id: ^another_account_id,
                user_id: ^user_id
              }} = Gains.update_gain(gain, params)
    end

    test "erro ao tentar raelizar update com os parâmtros inválidos", context do
      %{gain: gain} = context

      params = %{
        amount: 0,
        fix?: nil,
        account_id: 0
      }

      assert {:error, %Ecto.Changeset{errors: errors}} = Gains.update_gain(gain, params)

      assert errors:
               [
                 amount: {"must be greater than %{number}", _},
                 fix?: {"can't be blank", [validation: :required]},
                 account_id: {"is invalid", [type: :binary_id, validation: :cast]}
               ] = errors
    end
  end

  describe "delete_gain/2" do
    setup :setup_gains

    test "deleta de forma lógica o gain", %{gain: gain} do
      gain_id = gain.id
      assert {:ok, %Schema.Gain{id: ^gain_id}} = Gains.delete_gain(gain)

      assert %{deleted_at: deleted_at} = Gains.get_gain(gain_id)
      assert deleted_at != nil
    end
  end

  defp setup_category_gain(_), do: %{category: insert(:gain_category)}

  defp setup_gains(_) do
    user = insert(:user)

    account = insert(:account, user: user)

    gain = insert(:gain, user: user, account: account)

    %{user: user, account: account, gain: gain}
  end

  defp prepares_for_insert_gain(_) do
    user = insert(:user)

    category = insert(:gain_category)

    account = insert(:account, user: user)

    %{user: user, category: category, account: account}
  end
end
