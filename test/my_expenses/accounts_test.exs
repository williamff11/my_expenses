defmodule MyExpenses.AccountsTest do
  @moduledoc false

  use MyExpenses.Support.DataCase, async: true

  import MyExpenses.Support.Accounts
  import MyExpenses.Support.Users

  alias MyExpenses.Accounts
  alias MyExpenses.Accounts.Schema

  describe "list_accounts_by/1" do
    setup :setup_account

    test "erro caso a key user_id não for passada" do
      assert_raise RuntimeError, "key user_id is required", fn ->
        Accounts.list_accounts_by(%{num_account: "", type_account: :corrente})
      end
    end

    test "lista todas as contas do usuário", context do
      %{user: user, account: account} = context

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
                 name: name,
                 num_account: num_account,
                 type_account: type_account,
                 institution_id: institution_id,
                 description: _,
                 initial_amount_value: _,
                 user_id: user_id
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

  defp setup_account(_) do
    user = create_user()

    account = create_account(user)

    %{user: user, account: account}
  end
end
