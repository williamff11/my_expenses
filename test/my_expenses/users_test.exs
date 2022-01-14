defmodule MyExpenses.UserTest do
  use MyExpenses.Support.DataCase, async: true

  import MyExpenses.Support.Users

  alias MyExpenses.User
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
             ] = User.list_users()

      new_usuario = create_user()

      User.delete_user(new_usuario)

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
             ] = User.list_users()
    end

    test "lista todos os usuários deletados", context do
      %{user: user} = context

      User.delete_user(user)

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
             ] = User.list_only_trash()
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
             } = User.get_user(user_id)
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
             } = User.get_user(user_id)

      User.delete_user(user)
      refute User.get_user(user_id)
    end

    test "show usuario deletado", context do
      %{user: user} = context

      user_id = user.id

      User.delete_user(user)

      assert %Schema.User{
               id: ^user_id,
               name: _,
               email: _,
               phone: _,
               birth_date: _,
               cpf: _,
               login: _
             } = User.get_user_deleted(user_id)
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

      assert {:error, errors} = User.create_user(params)

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
                password: "123456",
                login: "michael",
                deleted_at: nil
              }} = User.create_user(params)
    end
  end

  describe "update_user" do
    setup :setup_user

    test "atualiza o usuário conforme parâmetros informados", context do
      %{user: user} = context

      user_id = user.id
      login_original = user.login
      password_original = user.password

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
                password: ^password_original,
                deleted_at: nil
              }} = User.update_user(user, params_update)
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
              }} = User.delete_user(user)

      assert deleted_at
    end
  end

  defp setup_user(_) do
    %{user: create_user()}
  end
end
