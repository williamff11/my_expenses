defmodule MyExpenses.AccountsTest do
  @moduledoc false

  use MyExpenses.Support.DataCase, async: true

  import MyExpenses.Factories

  alias MyExpenses.Accounts
  alias MyExpenses.Accounts.Schema

  describe "list_institutions/0" do
    setup :setup_institution

    test "lista todas as instituicoes cadatradas" do
      assert [%Schema.Institution{}] = Accounts.list_institutions()
    end
  end

  describe "list_accounts_by/1" do
    setup :setup_account

    test "erro caso a key user_id não for passada" do
      assert_raise RuntimeError, "key user_id is required", fn ->
        Accounts.list_accounts_by(%{num_account: "", type_account: :corrente})
      end
    end

    test "lista todas as contas do usuário", context do
      %{user: user} = context

      insert(:account, user: user)

      user_id = user.id

      assert [
               %Schema.Account{
                 name: _,
                 num_account: _,
                 description: _,
                 initial_amount_value: _,
                 type_account: _,
                 user_id: user_id,
                 institution: %Schema.Institution{}
               },
               %Schema.Account{
                 user_id: user_id
               }
             ] = Accounts.list_accounts_by(%{user_id: user_id})
    end

    test "lista todas as contas passadas como parâmetro", context do
      %{user: user, account: account} = context

      user_id = user.id

      name = account.name
      num_account = account.num_account
      type_account = account.type_account
      institution_id = account.institution.id

      assert [
               %Schema.Account{
                 name: ^name,
                 num_account: ^num_account,
                 type_account: ^type_account,
                 institution_id: ^institution_id,
                 description: _,
                 initial_amount_value: _,
                 user_id: ^user_id
               }
             ] =
               Accounts.list_accounts_by(%{
                 user_id: user_id,
                 name: name,
                 num_account: num_account,
                 type_account: type_account,
                 institution_id: institution_id
               })
    end
  end

  describe "get_accounts_by/2" do
    setup :setup_account

    test "retorna nil caso o usuario informado não seja o dono da conta", context do
      %{account: account} = context
      user = insert(:user)

      refute Accounts.get_account(user.id, account.id)
    end

    test "retorna nil caso a conta informada não seja do dono da conta", context do
      %{user: user} = context

      outher_user = insert(:user)
      account = insert(:account, user: outher_user)

      refute Accounts.get_account(user.id, account.id)
    end

    test "retorna a conta caso o usuario seja dono da conta", context do
      %{user: user, account: account} = context

      account_id = account.id
      user_id = user.id

      assert %Schema.Account{
               id: ^account_id,
               name: _,
               num_account: _,
               type_account: _,
               institution_id: _,
               description: _,
               initial_amount_value: _,
               user_id: ^user_id
             } = Accounts.get_account(user_id, account.id)
    end
  end

  describe "create_account/2" do
    setup :setup_account

    test "erro ao tentar cadastrar uma conta com os dados inválidos", context do
      %{user: user} = context

      institution = insert(:institution)

      params = %{
        name: "AB",
        num_account: "00-0",
        type_account: :type_random,
        institution_id: institution.id,
        description: "Erro ao tentar criar",
        initial_amount_value: 0
      }

      assert {:error, errors} = Accounts.create_account(user.id, params)

      assert [
               num_account: {"should be at least %{count} character(s)", _},
               name: {"should be at least %{count} character(s)", _},
               type_account: {"is invalid", _}
             ] = errors.errors
    end

    test "cria conta conforme os parâmetros informados", context do
      %{user: user} = context

      institution = insert(:institution)

      institution_id = institution.id

      params = %{
        name: "Account Test",
        num_account: "0076416-7",
        type_account: :corrente,
        institution_id: institution.id,
        description: "Sucess",
        initial_amount_value: 100
      }

      account = Accounts.create_account(user.id, params)

      amount_value = Decimal.new(100)

      assert {:ok,
              %Schema.Account{
                name: "Account Test",
                num_account: "0076416-7",
                type_account: :corrente,
                institution_id: ^institution_id,
                description: "Sucess",
                initial_amount_value: ^amount_value
              }} = account
    end
  end

  describe "update_account/2" do
    setup :setup_account

    test "erro ao passar uma conta que não pertence ao usuário informado", context do
      %{account: account} = context

      user = insert(:user)

      params = %{name: "change_name"}

      assert_raise RuntimeError, "account not found", fn ->
        Accounts.update_account(user.id, account.id, params)
      end
    end

    test "erro ao passar parâmetros inválidos", context do
      %{user: user, account: account} = context

      params = %{
        name: "change_name",
        num_account: "00-0",
        type_account: :agiotagem
      }

      assert {:error, errors} = Accounts.update_account(user.id, account.id, params)

      assert [
               num_account: {"should be at least %{count} character(s)", _},
               type_account: {"is invalid", _}
             ] = errors.errors
    end

    test "atualiza a conta conforme os parâmetros", context do
      %{user: user, account: account} = context

      params = %{
        name: "change_name",
        num_account: "0076416-7",
        type_account: :salario
      }

      assert {:ok,
              %Schema.Account{
                name: "change_name",
                num_account: "0076416-7",
                type_account: :salario,
                institution_id: _,
                description: _,
                initial_amount_value: _
              }} = Accounts.update_account(user.id, account.id, params)
    end
  end

  describe "delete_account/2" do
    setup :setup_account

    test "erro ao passar uma conta que não pertence ao usuário informado", context do
      %{account: account} = context

      user = insert(:user)

      assert_raise RuntimeError, "account not found", fn ->
        Accounts.delete_account(user.id, account.id)
      end
    end

    test "deleta a conta informada", context do
      %{user: user, account: account} = context

      account_id = account.id
      user_id = user.id

      assert {:ok,
              %Schema.Account{
                id: ^account_id,
                user_id: ^user_id
              }} = Accounts.delete_account(user_id, account_id)
    end
  end

  defp setup_account(_) do
    user = insert(:user)

    account = insert(:account, user: user)

    %{user: user, account: account}
  end

  defp setup_institution(_) do
    %{institution: insert(:institution)}
  end
end
