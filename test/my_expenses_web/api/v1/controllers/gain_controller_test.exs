defmodule MyExpensesWeb.Api.V1.Controllers.GainControllerTest do
  use MyExpensesWeb.ConnCase

  import MyExpenses.Factories

  @endpoint_gains "/api/v1/gains"
  @endpoint_gain_categories "/api/v1/gain_categories"

  setup do
    user = insert(:user)

    %{user: user, gain_category: insert(:gain_category), gain: insert(:gain, user: user)}
  end

  describe "auth" do
    test "returns 401 when user isn't authenticated" do
      result =
        build_conn()
        |> get(@endpoint_gains)
        |> json_response(401)

      assert %{"reason" => "missing_authorization_header"} = result
    end
  end

  describe "GET - gain_category" do
    test "index - returns 200 and list all gain category when user is authenticated", %{conn: conn, user: user} do
      result =
        conn
        |> authenticated(user)
        |> get(@endpoint_gain_categories)
        |> json_response(200)

      assert [%{"id" => _, "icon" => _} | _] = result
    end

    test "show - returns 200 and show gain category by params when user is authenticated", context do
      %{conn: conn, user: user, gain_category: gain_category} = context

      gain_category_id = gain_category.id

      params = %{id: gain_category_id}

      result =
        conn
        |> authenticated(user)
        |> get(@endpoint_gain_categories <> "/#{gain_category_id}", params)
        |> json_response(200)

      assert %{"color" => _, "id" => ^gain_category_id} = result
    end
  end

  describe "POST - gain_category" do
    test "return a new gain category when the data is valid", %{user: user} do
      gain_category_params = params_for(:gain_category, color: "#FFF")

      result =
        build_conn()
        |> authenticated(user)
        |> post(@endpoint_gain_categories, %{"gain_category" => gain_category_params})
        |> json_response(201)

      assert %{"color" => "#FFF"} = result
    end

    test "return errors when try create a new gain category whit invalid data", %{user: user} do
      gain_category_params = params_for(:gain_category, name: nil)

      result =
        build_conn()
        |> authenticated(user)
        |> post(@endpoint_gain_categories, %{"gain_category" => gain_category_params})
        |> json_response(422)

      assert %{"name" => ["can't be blank"]} = result
    end
  end

  describe "PUT - gain category" do
    test "update - 200 gain category with valid data", %{user: user, gain_category: gain_category} do
      %{id: gain_category_id} = gain_category

      params = %{color: "#FFF"}

      result =
        build_conn()
        |> authenticated(user)
        |> put(@endpoint_gain_categories <> "/#{gain_category_id}", %{"gain_category" => params})
        |> json_response(200)

      assert %{"color" => "#FFF"} = result
    end

    test "returns 422 when the data is invalid", %{user: user, gain_category: gain_category} do
      %{id: gain_category_id} = gain_category

      params = %{name: nil}

      result =
        build_conn()
        |> authenticated(user)
        |> put(@endpoint_gain_categories <> "/#{gain_category_id}", %{"gain_category" => params})
        |> json_response(422)

      assert %{"name" => ["can't be blank"]} = result
    end
  end

  describe "DELETE - gain category" do
    test "delete gain_category", %{user: user, gain_category: gain_category} do
      %{id: id} = gain_category

      build_conn()
      |> authenticated(user)
      |> delete(@endpoint_gain_categories <> "/#{id}")
      |> json_response(204)
    end
  end

  describe "GET - gains" do
    test "index - returns 200 and list all gains by user when user is authenticated", %{conn: conn, user: user} do
      user_id = user.id

      insert(:gain)

      result =
        conn
        |> authenticated(user)
        |> get(@endpoint_gains)
        |> json_response(200)

      assert [
               %{"id" => _, "amount" => _, "user_id" => ^user_id, "gain_category_id" => _, "account_id" => _}
             ] = result
    end

    test "show - returns 200 and show gain by params when user is authenticated", context do
      %{conn: conn, user: user, gain: gain} = context

      gain_id = gain.id
      user_id = user.id

      params = %{id: gain_id}

      result =
        conn
        |> authenticated(user)
        |> get(@endpoint_gains <> "/#{gain_id}", params)
        |> json_response(200)

      assert %{"user_id" => ^user_id, "amount" => _, "id" => ^gain_id} = result
    end

    test "show - returns just accounts from with user_id equal id of user" do
      user = insert(:user)

      %{id: gain_id} = insert(:gain)

      result =
        build_conn()
        |> authenticated(user)
        |> get(@endpoint_gains <> "/#{gain_id}")
        |> json_response(200)

      refute result
    end
  end

  describe "POST - gains" do
    test "return a new gain when the data is valid", %{user: user} do
      gain_params = params_for(:gain, user: user)

      result =
        build_conn()
        |> authenticated(user)
        |> post(@endpoint_gains, %{"gain" => gain_params})
        |> json_response(201)

      user_id = user.id

      assert %{"user_id" => ^user_id} = result
    end

    test "return errors when try create a new gain whit invalid data", %{user: user} do
      gain_params = params_for(:gain, user: user, amount: -1)

      result =
        build_conn()
        |> authenticated(user)
        |> post(@endpoint_gains, %{"gain" => gain_params})
        |> json_response(422)

      assert %{"amount" => ["must be greater than 0"]} = result
    end
  end

  describe "PUT - gains" do
    test "update - 200 gain with valid data", %{user: user, gain: gain} do
      %{id: gain_id} = gain

      params = %{amount: Decimal.new("101")}

      result =
        build_conn()
        |> authenticated(user)
        |> put(@endpoint_gains <> "/#{gain_id}", %{"gain" => params})
        |> json_response(200)

      assert %{"amount" => "101"} = result
    end

    test "doesn't update the value of user_id", %{user: user, gain: gain} do
      %{id: gain_id, user_id: user_id} = gain

      params = %{user_id: Faker.UUID.v4()}

      result =
        build_conn()
        |> authenticated(user)
        |> put(@endpoint_gains <> "/#{gain_id}", %{"gain" => params})
        |> json_response(200)

      assert %{"user_id" => ^user_id} = result
    end

    test "returns 422 when the data is invalid", %{user: user, gain: gain} do
      %{id: gain_id} = gain

      params = %{amount: nil}

      result =
        build_conn()
        |> authenticated(user)
        |> put(@endpoint_gains <> "/#{gain_id}", %{"gain" => params})
        |> json_response(422)

      assert %{"amount" => ["can't be blank"]} = result
    end
  end

  describe "DELETE - gains" do
    test "delete gain", %{user: user, gain: gain} do
      %{id: id} = gain

      build_conn()
      |> authenticated(user)
      |> delete(@endpoint_gains <> "/#{id}")
      |> json_response(204)
    end
  end
end
