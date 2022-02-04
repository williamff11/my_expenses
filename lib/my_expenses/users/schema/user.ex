defmodule MyExpenses.Users.Schema.User do
  @moduledoc """
    Schema de usuário
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t() :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          email: String.t(),
          phone: String.t(),
          birth_date: Date.t(),
          cpf: String.t(),
          login: String.t(),
          password: String.t(),
          deleted_at: DateTime.t(),
          created_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}

  @derive {Jason.Encoder, except: [:__meta__, :__struct__, :salt, :password]}

  schema "users" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :birth_date, :date
    field :cpf, :string
    field :login, :string
    field :salt, :string, redact: true
    field :password, :string, redact: true

    field :deleted_at, :utc_datetime

    timestamps(
      inserted_at: :created_at,
      updated_at: :updated_at,
      type: :utc_datetime
    )
  end

  def create_changeset(%__MODULE__{} = struct, params) do
    fields = [
      :name,
      :email,
      :phone,
      :birth_date,
      :cpf,
      :login,
      :password
    ]

    struct
    |> cast(params, fields)
    |> validate_changeset(fields)
    |> encrypt_password()
  end

  @spec update_changeset(
          MyExpenses.Users.Schema.User.t(),
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = struct, params) do
    fields = [:email, :phone, :password]

    struct
    |> cast(params, fields)
    |> validate_changeset(fields)
    |> encrypt_password()
  end

  defp validate_changeset(changeset, fields) do
    changeset
    |> validate_required(fields)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:name, min: 3, max: 80)
    |> validate_length(:email, min: 8, max: 180)
    |> validate_length(:password, min: 5, max: 18)
    |> validate_length(:phone, min: 10, max: 15)
    |> validate_length(:cpf, min: 11, max: 14)
  end

  defp encrypt_password(%Ecto.Changeset{} = changeset) do
    password = get_field(changeset, :password)

    if changeset.valid? do
      salt = generate_salt()

      password_encrypted =
        :sha512
        |> :crypto.hash(password <> salt)
        |> Base.encode16()
        |> String.downcase()

      changeset
      |> put_change(:password, password_encrypted)
      |> put_change(:salt, salt)
    else
      changeset
    end
  end

  def generate_salt() do
    alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    numbers = "0123456789"

    lists = String.split(alphabets <> String.downcase(alphabets) <> numbers, "", trim: true)

    do_randomizer(Enum.random(10..15), lists)
  end

  @doc false
  defp get_range(length) when length > 1, do: 1..length

  @doc false
  defp do_randomizer(length, lists) do
    length
    |> get_range()
    |> Enum.reduce([], fn _, acc -> [Enum.random(lists) | acc] end)
    |> Enum.join("")
  end
end
