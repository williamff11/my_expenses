defmodule MyExpensesWeb.Api.V1.Controllers.AuthControllerTest do
  use MyExpensesWeb.ConnCase

  import MyExpenses.Factories

  @endpoint_accounts "/api/v1/accounts"
  @endpoint_login "api/v1/login"

  @salt "salt123"

  describe "login" do
    test "when gives the right email and password, returns status code 200 a token and the user" do
      password = "123456"
      email = "w123@f.com"

      %{name: name} = insert(:user, email: email, password: encrypt_password(password), salt: @salt)

      params_login = %{email: email, password: password}

      result =
        build_conn()
        |> post(@endpoint_login, %{"credentials" => params_login})
        |> json_response(200)

      assert %{"token" => _, "user" => %{"name" => ^name}} = result
    end

    test "when gives wrong credentials, returns status code 400" do
      password = "123456"
      email = "w123@f.com"

      insert(:user, email: email, password: encrypt_password(password), salt: @salt)

      params_login = %{email: email, password: "12345"}

      result =
        build_conn()
        |> post(@endpoint_login, %{"credentials" => params_login})
        |> json_response(400)

      assert %{"error" => "Invalid credentials"} = result
    end

    test "when the user is deleted, returns status code 400" do
      password = "123456"
      email = "w123@f.com"

      insert(:user, email: email, password: encrypt_password(password), salt: @salt, deleted_at: Timex.now())

      params_login = %{email: email, password: "123456"}

      result =
        build_conn()
        |> post(@endpoint_login, %{"credentials" => params_login})
        |> json_response(400)

      assert %{"error" => "Inactive user"} = result
    end
  end

  describe "token" do
    test "verify if the returned token is a valid token" do
      password = "123456"
      email = "w123@f.com"

      insert(:user, email: email, password: encrypt_password(password), salt: @salt)

      params_login = %{email: email, password: password}

      assert %{"token" => token} =
               build_conn()
               |> post(@endpoint_login, %{"credentials" => params_login})
               |> json_response(200)

      build_conn()
      |> Plug.Conn.put_req_header("authorization", "Bearer #{token}")
      |> get(@endpoint_accounts)
      |> json_response(200)
    end
  end

  defp encrypt_password(password) do
    :sha512
    |> :crypto.hash(password <> @salt)
    |> Base.encode16()
    |> String.downcase()
  end
end
