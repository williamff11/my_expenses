defmodule MyExpensesWeb.Api.V1.Controllers.UserControllerTest do
  use MyExpensesWeb.ConnCase

  import MyExpenses.Factories

  @endpoint_users "/api/v1/users"

  setup do
    %{user: insert(:user)}
  end

  describe "auth" do
    test "returns 401 when user isn't authenticated" do
      result =
        build_conn()
        |> get(@endpoint_users)
        |> json_response(401)

      assert %{"reason" => "missing_authorization_header"} = result
    end
  end

  describe "GET - user" do
    test "index - returns 200 and list all user when user is authenticated", %{conn: conn, user: user} do
      result =
        conn
        |> authenticated(user)
        |> get(@endpoint_users)
        |> json_response(200)

      assert [%{"id" => _, "email" => _} | _] = result
    end

    test "show - returns 200 and show user by params when user is authenticated", context do
      %{conn: conn, user: user} = context

      user_id = user.id

      params = %{id: user_id}

      result =
        conn
        |> authenticated(user)
        |> get(@endpoint_users <> "/#{user_id}", params)
        |> json_response(200)

      assert %{"email" => _, "id" => ^user_id} = result
    end
  end

  describe "POST - user" do
    test "return a new user  when the data is valid", %{user: user} do
      user_params = params_for(:user, email: "w123@f.com")

      result =
        build_conn()
        |> authenticated(user)
        |> post(@endpoint_users, %{"user" => user_params})
        |> json_response(201)

      assert %{"email" => "w123@f.com"} = result
    end

    test "return errors when try create a new user whit invalid data", %{user: user} do
      user_params = params_for(:user, name: nil)

      result =
        build_conn()
        |> authenticated(user)
        |> post(@endpoint_users, %{"user" => user_params})
        |> json_response(422)

      assert %{"name" => ["can't be blank"]} = result
    end
  end

  describe "PUT - user" do
    test "update - 200 user  with valid data", %{user: user} do
      %{id: user_id} = user

      params = %{email: "w123@f.com"}

      result =
        build_conn()
        |> authenticated(user)
        |> put(@endpoint_users <> "/#{user_id}", %{"user" => params})
        |> json_response(200)

      assert %{"email" => "w123@f.com"} = result
    end

    test "returns 422 when the data is invalid", %{user: user} do
      %{id: user_id} = user

      params = %{email: nil}

      result =
        build_conn()
        |> authenticated(user)
        |> put(@endpoint_users <> "/#{user_id}", %{"user" => params})
        |> json_response(422)

      assert %{"email" => ["can't be blank"]} = result
    end
  end

  describe "DELETE - user" do
    test "delete gain", %{user: user} do
      %{id: id} = user

      build_conn()
      |> authenticated(user)
      |> delete(@endpoint_users <> "/#{id}")
      |> json_response(204)
    end
  end
end
