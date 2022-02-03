defmodule MyExpensesWeb.Api.V1.Controllers.AccountControllerTest do
  use MyExpensesWeb.ConnCase

  import MyExpenses.Factories

  @endpoint_accounts "/api/v1/accounts"

  setup do
    user = insert(:user)

    %{user: user, account: insert(:account, user: user)}
  end

  describe "auth" do
    test "returns 401 when user isn't authenticated" do
      result =
        build_conn()
        |> get(@endpoint_accounts)
        |> json_response(401)

      assert %{"reason" => "missing_authorization_header"} = result
    end
  end

  describe "GET - accounts" do
    test "index - returns 200 and list all accounts by user when user is authenticated", %{conn: conn, user: user} do
      user_id = user.id

      insert(:account)

      result =
        conn
        |> authenticated(user)
        |> get(@endpoint_accounts)
        |> json_response(200)

      assert [
               %{"id" => _, "num_account" => _, "user_id" => ^user_id}
             ] = result
    end

    test "show - returns 200 and show account by params when user is authenticated", context do
      %{conn: conn, user: user, account: account} = context

      account_id = account.id
      user_id = user.id

      params = %{id: account_id}

      result =
        conn
        |> authenticated(user)
        |> get(@endpoint_accounts <> "/#{account_id}", params)
        |> json_response(200)

      assert %{"user_id" => ^user_id, "num_account" => _, "id" => ^account_id} = result
    end

    test "get - returns just accounts from with user_id equal id of user" do
      user = insert(:user)

      %{id: account_id} = insert(:account)

      result =
        build_conn()
        |> authenticated(user)
        |> get(@endpoint_accounts <> "/#{account_id}")
        |> json_response(200)

      refute result
    end
  end

  describe "POST - accounts" do
    test "return a new account when the data is valid", %{user: user} do
      account_params = params_for(:account, user: user)

      result =
        build_conn()
        |> authenticated(user)
        |> post(@endpoint_accounts, %{"account" => account_params})
        |> json_response(201)

      user_id = user.id

      assert %{"user_id" => ^user_id} = result
    end

    test "return errors when try create a new account whit invalid data", %{user: user} do
      account_params = params_for(:account, user: user, num_account: nil)

      result =
        build_conn()
        |> authenticated(user)
        |> post(@endpoint_accounts, %{"account" => account_params})
        |> json_response(422)

      assert %{"num_account" => ["can't be blank"]} = result
    end
  end

  describe "PUT - accounts" do
    test "update - 200 account with valid data", %{user: user, account: account} do
      %{id: account_id} = account

      params = %{num_account: "158764"}

      result =
        build_conn()
        |> authenticated(user)
        |> put(@endpoint_accounts <> "/#{account_id}", %{"account" => params})
        |> json_response(200)

      assert %{"num_account" => "158764"} = result
    end

    test "doesn't update the value of user_id", %{user: user, account: account} do
      %{id: account_id, user_id: user_id} = account

      params = %{user_id: Faker.UUID.v4()}

      result =
        build_conn()
        |> authenticated(user)
        |> put(@endpoint_accounts <> "/#{account_id}", %{"account" => params})
        |> json_response(200)

      assert %{"user_id" => ^user_id} = result
    end

    test "returns 422 when the data is invalid", %{user: user, account: account} do
      %{id: account_id} = account

      params = %{num_account: nil}

      result =
        build_conn()
        |> authenticated(user)
        |> put(@endpoint_accounts <> "/#{account_id}", %{"account" => params})
        |> json_response(422)

      assert %{"num_account" => ["can't be blank"]} = result
    end
  end

  describe "DELETE - accounts" do
    test "delete account", %{user: user, account: account} do
      %{id: id} = account

      build_conn()
      |> authenticated(user)
      |> delete(@endpoint_accounts <> "/#{id}")
      |> json_response(204)
    end
  end
end
