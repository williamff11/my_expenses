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

  @derive {Jason.Encoder, except: [:__meta__, :__struct__]}

  schema "users" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :birth_date, :date
    field :cpf, :string
    field :login, :string
    field :password, :string

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
  end

  defp validate_changeset(changeset, fields) do
    changeset
    |> validate_required(fields)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:name, min: 3, max: 80)
    |> validate_length(:email, min: 8, max: 180)
    |> validate_length(:phone, min: 10, max: 15)
    |> validate_length(:cpf, min: 11, max: 14)
  end
end
