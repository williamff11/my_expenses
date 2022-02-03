defmodule MyExpensesWeb.Api.V1.Controllers.ExpensesControllerTest do
  use MyExpensesWeb.ConnCase

  import MyExpenses.Factories

  @endpoint_expenses "/api/v1/expenses"
  @endpoint_expense_categories "/api/v1/expense_categories"

  setup do
    user = insert(:user)

    %{user: user, expense_category: insert(:expense_category), expense: insert(:expense, user: user)}
  end

  describe "auth" do
    test "returns 401 when user isn't authenticated" do
      result =
        build_conn()
        |> get(@endpoint_expenses)
        |> json_response(401)

      assert %{"reason" => "missing_authorization_header"} = result
    end
  end

  describe "GET - expense_category" do
    test "index - returns 200 and list all expense category when user is authenticated", %{conn: conn, user: user} do
      result =
        conn
        |> authenticated(user)
        |> get(@endpoint_expense_categories)
        |> json_response(200)

      assert [%{"id" => _, "icon" => _} | _] = result
    end

    test "show - returns 200 and show expense category by params when user is authenticated", context do
      %{conn: conn, user: user, expense_category: expense_category} = context

      expense_category_id = expense_category.id

      params = %{id: expense_category_id}

      result =
        conn
        |> authenticated(user)
        |> get(@endpoint_expense_categories <> "/#{expense_category_id}", params)
        |> json_response(200)

      assert %{"color" => _, "id" => ^expense_category_id} = result
    end
  end

  describe "POST - expense_category" do
    test "return a new expense category when the data is valid", %{user: user} do
      expense_category_params = params_for(:expense_category, color: "#FFF")

      result =
        build_conn()
        |> authenticated(user)
        |> post(@endpoint_expense_categories, %{"expense_category" => expense_category_params})
        |> json_response(201)

      assert %{"color" => "#FFF"} = result
    end

    test "return errors when try create a new expense category whit invalid data", %{user: user} do
      expense_category_params = params_for(:expense_category, name: nil)

      result =
        build_conn()
        |> authenticated(user)
        |> post(@endpoint_expense_categories, %{"expense_category" => expense_category_params})
        |> json_response(422)

      assert %{"name" => ["can't be blank"]} = result
    end
  end

  describe "PUT - expense category" do
    test "update - 200 expense category with valid data", %{user: user, expense_category: expense_category} do
      %{id: expense_category_id} = expense_category

      params = %{color: "#FFF"}

      result =
        build_conn()
        |> authenticated(user)
        |> put(@endpoint_expense_categories <> "/#{expense_category_id}", %{"expense_category" => params})
        |> json_response(200)

      assert %{"color" => "#FFF"} = result
    end

    test "returns 422 when the data is invalid", %{user: user, expense_category: expense_category} do
      %{id: expense_category_id} = expense_category

      params = %{name: nil}

      result =
        build_conn()
        |> authenticated(user)
        |> put(@endpoint_expense_categories <> "/#{expense_category_id}", %{"expense_category" => params})
        |> json_response(422)

      assert %{"name" => ["can't be blank"]} = result
    end
  end

  describe "DELETE - expense category" do
    test "delete expense_category", %{user: user, expense_category: expense_category} do
      %{id: id} = expense_category

      build_conn()
      |> authenticated(user)
      |> delete(@endpoint_expense_categories <> "/#{id}")
      |> json_response(204)
    end
  end

  describe "GET - expenses" do
    test "index - returns 200 and list all expenses by user when user is authenticated", %{conn: conn, user: user} do
      user_id = user.id

      insert(:expense)

      result =
        conn
        |> authenticated(user)
        |> get(@endpoint_expenses)
        |> json_response(200)

      assert [
               %{"id" => _, "amount" => _, "user_id" => ^user_id, "expense_category_id" => _}
             ] = result
    end

    test "show - returns 200 and show expense by params when user is authenticated", context do
      %{conn: conn, user: user, expense: expense} = context

      expense_id = expense.id
      user_id = user.id

      params = %{id: expense_id}

      result =
        conn
        |> authenticated(user)
        |> get(@endpoint_expenses <> "/#{expense_id}", params)
        |> json_response(200)

      assert %{"user_id" => ^user_id, "amount" => _, "id" => ^expense_id} = result
    end

    test "show - returns just accounts from with user_id equal id of user" do
      user = insert(:user)

      %{id: expense_id} = insert(:expense)

      result =
        build_conn()
        |> authenticated(user)
        |> get(@endpoint_expenses <> "/#{expense_id}")
        |> json_response(200)

      refute result
    end
  end

  describe "POST - expenses" do
    test "return a new expense when the data is valid", %{user: user} do
      expense_params = params_for(:expense, user: user)

      result =
        build_conn()
        |> authenticated(user)
        |> post(@endpoint_expenses, %{"expense" => expense_params})
        |> json_response(201)

      user_id = user.id

      assert %{"user_id" => ^user_id} = result
    end

    test "return errors when try create a new expense whit invalid data", %{user: user} do
      expense_params = params_for(:expense, user: user, amount: -1)

      result =
        build_conn()
        |> authenticated(user)
        |> post(@endpoint_expenses, %{"expense" => expense_params})
        |> json_response(422)

      assert %{"amount" => ["must be greater than 0"]} = result
    end
  end

  describe "PUT - expenses" do
    test "update - 200 expense with valid data", %{user: user, expense: expense} do
      %{id: expense_id} = expense

      params = %{amount: Decimal.new("101")}

      result =
        build_conn()
        |> authenticated(user)
        |> put(@endpoint_expenses <> "/#{expense_id}", %{"expense" => params})
        |> json_response(200)

      assert %{"amount" => "101"} = result
    end

    test "doesn't update the value of user_id", %{user: user, expense: expense} do
      %{id: expense_id, user_id: user_id} = expense

      params = %{user_id: Faker.UUID.v4()}

      result =
        build_conn()
        |> authenticated(user)
        |> put(@endpoint_expenses <> "/#{expense_id}", %{"expense" => params})
        |> json_response(200)

      assert %{"user_id" => ^user_id} = result
    end

    test "returns 422 when the data is invalid", %{user: user, expense: expense} do
      %{id: expense_id} = expense

      params = %{amount: nil}

      result =
        build_conn()
        |> authenticated(user)
        |> put(@endpoint_expenses <> "/#{expense_id}", %{"expense" => params})
        |> json_response(422)

      assert %{"amount" => ["can't be blank"]} = result
    end
  end

  describe "DELETE - expenses" do
    test "delete expense", %{user: user, expense: expense} do
      %{id: id} = expense

      build_conn()
      |> authenticated(user)
      |> delete(@endpoint_expenses <> "/#{id}")
      |> json_response(204)
    end
  end
end
