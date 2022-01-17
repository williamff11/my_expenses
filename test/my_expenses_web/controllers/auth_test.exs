defmodule MyExpensesWeb.Api.AuthTest do
  use MyExpenses.Support.DataCase, async: true

  use Plug.Test

  import MyExpenses.Factories

  alias MyExpenses.Users.Schema.User

  setup do
    secret = "1234"

    opts = MyExpensesWeb.Auth.init(secret_key: secret)

    user = insert(:user)

    %{opts: opts, user: user, secret: secret}
  end

  test "retorna 401 caso não seja informado o header 'authorization'", %{opts: opts} do
    conn = :get |> conn("/") |> MyExpensesWeb.Auth.call(opts)

    assert %{status: 401, state: :sent, halted: true} = conn
    assert %{reason: "missing_authorization_header"} = decode_body(conn)
  end

  test "retorna 401 caso o seja informado um token inválido", context do
    %{opts: opts, user: user, secret: secret} = context

    conn = conn(:get, "/")

    jwt = generate_token_jwt(secret, user)

    conn1 = conn |> put_req_header("authorization", "123") |> MyExpensesWeb.Auth.call(opts)
    conn2 = conn |> put_req_header("authorization", jwt) |> MyExpensesWeb.Auth.call(opts)
    conn3 = conn |> put_req_header("authorization", "Bearer 123") |> MyExpensesWeb.Auth.call(opts)

    assert %{status: 401, state: :sent, halted: true} = conn1
    assert %{reason: "invalid_authorization_header"} = decode_body(conn1)

    assert %{status: 401, state: :sent, halted: true} = conn2
    assert %{reason: "invalid_authorization_header"} = decode_body(conn2)

    assert %{status: 401, state: :sent, halted: true} = conn3
    assert %{reason: "bad_jwt_format"} = decode_body(conn3)
  end

  test "retorna 401 caso seja informado um token assinado com uma outra secret", context do
    %{opts: opts, user: user} = context

    token = generate_token_jwt("4321", user)

    conn =
      :get
      |> conn("/")
      |> put_req_header("authorization", "Bearer #{token}")
      |> MyExpensesWeb.Auth.call(opts)

    assert %{status: 401, state: :sent, halted: true} = conn
    assert %{reason: "invalid_signature"} = decode_body(conn)
  end

  test "retorna 401 caso o token esteja expirado", context do
    %{opts: opts, user: user, secret: secret} = context

    token = generate_token_jwt(secret, user, %{"exp" => 1000})

    conn =
      :get
      |> conn("/")
      |> put_req_header("authorization", "Bearer #{token}")
      |> MyExpensesWeb.Auth.call(opts)

    assert %{status: 401, state: :sent, halted: true} = conn
    assert %{reason: "token_expired"} = decode_body(conn)
  end

  test "adiciona o usuário e o JWT nos assigns da conn caso seja um token válido", context do
    %{opts: opts, user: user, secret: secret} = context

    user_id = user.id

    token = generate_token_jwt(secret, user)

    conn =
      :get
      |> conn("/")
      |> put_req_header("authorization", "Bearer #{token}")
      |> MyExpensesWeb.Auth.call(opts)

    assert %{
             status: nil,
             resp_body: nil,
             halted: false,
             assigns: %{
               jwt: %JOSE.JWT{},
               user: %User{id: ^user_id}
             }
           } = conn
  end

  defp generate_token_jwt(secret, user, params \\ %{}) do
    expiration_in_millisecond = :os.system_time(:millisecond) + :timer.minutes(5)

    params =
      Enum.into(params, %{
        "user" => user.id,
        "exp" => expiration_in_millisecond / 1000
      })

    secret
    |> JOSE.JWK.from_oct()
    |> JOSE.JWT.sign(%{"alg" => "HS256"}, params)
    |> JOSE.JWS.compact()
    |> elem(1)
  end

  defp decode_body(conn) do
    Jason.decode!(conn.resp_body, keys: :atoms)
  end
end
