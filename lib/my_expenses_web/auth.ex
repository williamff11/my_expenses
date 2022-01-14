defmodule MyExpensesWeb.Auth do
  @moduledoc false

  import Plug.Conn

  alias MyExpenses.Users
  alias Phoenix.Controller

  def init(options) do
    jwk =
      :my_expenses
      |> Application.get_env(__MODULE__)
      |> Keyword.merge(options || [])
      |> Keyword.fetch!(:secret_key)
      |> JOSE.JWK.from_oct()

    %{jwk: jwk}
  end

  def call(%Plug.Conn{} = conn, opts) do
    with {:ok, header} <- fetch_authorization_header(conn),
         {:ok, token} <- extract_token_from_header(header),
         {:ok, jwt} <- validate_token(token, opts),
         {:ok, jwt} <- validate_jwt_expiration(jwt),
         {:ok, user} <- fetch_user_from_jwt(jwt) do
      conn
      |> assign(:jwt, jwt)
      |> assign(:user, user)
    else
      {:error, reason} ->
        conn
        |> put_status(401)
        |> Controller.json(%{reason: reason})
        |> halt()
    end
  end

  defp fetch_authorization_header(conn) do
    case get_req_header(conn, "authorization") do
      [header] -> {:ok, header}
      _ -> {:error, :missing_authorization_header}
    end
  end

  defp extract_token_from_header("Bearer " <> token) do
    {:ok, token}
  end

  defp extract_token_from_header(_) do
    {:error, :invalid_authorization_header}
  end

  defp validate_token(header, opts) do
    case JOSE.JWT.verify_strict(opts.jwk, ["HS256"], header) do
      {true, jwt, _jws} -> {:ok, jwt}
      {false, _jwt, _jws} -> {:error, :invalid_signature}
      {:error, {:badarg, _}} -> {:error, :bad_jwt_format}
    end
  end

  defp validate_jwt_expiration(jwt) do
    actual_timestamp = :os.system_time(:seconds)

    case jwt do
      %{fields: %{"exp" => exp}} when exp > actual_timestamp -> {:ok, jwt}
      _ -> {:error, :token_expired}
    end
  end

  defp fetch_user_from_jwt(%{fields: %{"user" => user_id}}) do
    user = Users.get_user(user_id)

    case user do
      nil -> {:ok, :user_not_found}
      user -> {:ok, user}
    end
  end
end
