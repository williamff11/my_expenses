defmodule MyExpenses.Auth do
  @moduledoc """
  Module responsible for generate token and do login to user
  """
  alias MyExpenses.Users.Schema.User

  @secret Application.compile_env!(:my_expenses, [MyExpensesWeb.Auth, :secret_key])

  def do_login(email, password) do
    with %User{deleted_at: deleted_at} = user <- MyExpenses.Repo.get_by(User, email: email),
         nil <- deleted_at,
         true <- password_is_valid?(user, password) do
      token = generate_token(user)

      {:ok, %{token: token, user: user}}
    else
      %DateTime{} -> {:error, "Inactive user"}
      _ -> {:error, "Invalid credentials"}
    end
  end

  defp password_is_valid?(%User{salt: salt, password: password_encrypted}, password),
    do: generate_hash(password, salt) == password_encrypted

  defp generate_hash(password, salt) do
    :sha512
    |> :crypto.hash(password <> salt)
    |> Base.encode16()
    |> String.downcase()
  end

  defp generate_token(user) do
    expiration_in_millisecond = :os.system_time(:millisecond) + :timer.minutes(5)

    params = %{
      "user" => user.id,
      "exp" => expiration_in_millisecond / 1000
    }

    @secret
    |> JOSE.JWK.from_oct()
    |> JOSE.JWT.sign(%{"alg" => "HS256"}, params)
    |> JOSE.JWS.compact()
    |> elem(1)
  end
end
