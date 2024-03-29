defmodule MyExpenses.UserTest do
  use MyExpenses.Support.DataCase, async: true

  import MyExpenses.Factories

  alias MyExpenses.Users
  alias MyExpenses.Users.Schema

  describe "list_usuarios" do
    setup :setup_user

    test "lista todos os usuários ativos", context do
      %{user: user} = context

      user_id = user.id

      assert [
               %Schema.User{
                 id: ^user_id,
                 name: _,
                 email: _,
                 phone: _,
                 birth_date: _,
                 cpf: _,
                 login: _,
                 deleted_at: nil
               }
             ] = Users.list_users()

      new_usuario = insert(:user)

      Users.delete_user(new_usuario)

      assert [
               %Schema.User{
                 id: ^user_id,
                 name: _,
                 email: _,
                 phone: _,
                 birth_date: _,
                 cpf: _,
                 login: _,
                 deleted_at: nil
               }
             ] = Users.list_users()
    end

    test "lista todos os usuários deletados", context do
      %{user: user} = context

      Users.delete_user(user)

      assert [
               %Schema.User{
                 id: _,
                 name: _,
                 email: _,
                 phone: _,
                 birth_date: _,
                 cpf: _,
                 login: _,
                 password: _,
                 deleted_at: _
               }
             ] = Users.list_only_trash()
    end
  end

  describe "get_user" do
    setup :setup_user

    test "show usuario", context do
      %{user: %{id: user_id}} = context

      assert %Schema.User{
               id: ^user_id,
               name: _,
               email: _,
               phone: _,
               birth_date: _,
               cpf: _,
               login: _
             } = Users.get_user(user_id)
    end

    test "só mostra o usuário caso ele não esteja deletado", context do
      %{user: user} = context

      user_id = user.id

      assert %Schema.User{
               id: ^user_id,
               name: _,
               email: _,
               phone: _,
               birth_date: _,
               cpf: _,
               login: _
             } = Users.get_user(user_id)

      assert {:ok, %{deleted_at: deleted_at}} = Users.delete_user(user)
      refute deleted_at == nil
    end

    test "show usuario deletado", context do
      %{user: user} = context

      user_id = user.id

      Users.delete_user(user)

      assert %Schema.User{
               id: ^user_id,
               name: _,
               email: _,
               phone: _,
               birth_date: _,
               cpf: _,
               login: _
             } = Users.get_user_deleted(user_id)
    end
  end

  describe "create_user" do
    test "retorna erro ao tentar passar parâmetros incorretos" do
      params = %{
        name: "Michael Scott",
        email: "usuario@usuario.com",
        phone: "69999998888",
        password: "123456"
      }

      assert {:error, errors} = Users.create_user(params)

      assert errors_on(errors) == %{
               birth_date: ["can't be blank"],
               cpf: ["can't be blank"],
               login: ["can't be blank"]
             }
    end

    test "cria usuário conforme parâmetros passados" do
      params = %{
        name: "Michael Scott",
        cpf: "84570655599",
        email: "usuario@usuario.com",
        phone: "69999998888",
        birth_date: ~D[2020-01-01],
        login: "michael",
        password: "123456"
      }

      assert {:ok,
              %Schema.User{
                name: "Michael Scott",
                cpf: "84570655599",
                email: "usuario@usuario.com",
                phone: "69999998888",
                birth_date: ~D[2020-01-01],
                salt: _,
                password: _,
                login: "michael",
                deleted_at: nil
              }} = Users.create_user(params)
    end
  end

  describe "update_user" do
    setup :setup_user

    test "atualiza o usuário conforme parâmetros informados", context do
      %{user: user} = context

      user_id = user.id
      login_original = user.login

      params_update = %{email: "michael@scott.com", phone: "69998741593"}

      assert {:ok,
              %Schema.User{
                id: ^user_id,
                name: _,
                email: "michael@scott.com",
                phone: "69998741593",
                birth_date: _,
                cpf: _,
                login: ^login_original,
                salt: _,
                password: _,
                deleted_at: nil
              }} = Users.update_user(user, params_update)
    end
  end

  describe "delete_user" do
    setup :setup_user

    test "realiza um soft delete no usuario conforme passado", context do
      %{user: user} = context

      user_id = user.id

      assert {:ok,
              %Schema.User{
                id: ^user_id,
                deleted_at: deleted_at
              }} = Users.delete_user(user)

      assert deleted_at
    end
  end

  defp setup_user(_) do
    %{user: insert(:user)}
  end
end
