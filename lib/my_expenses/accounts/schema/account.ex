defmodule MyExpenses.Accounts.Schema.Account do
  @moduledoc """
  Módulo responsável pelas contas que serão cadastradas pelo usuário e inserida gastos e despesas.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias MyExpenses.Accounts.Schema
  alias MyExpenses.Accounts.Types

  @type t() :: %__MODULE__{
          name: String.t(),
          description: String.t(),
          num_account: String.t(),
          initial_amount_value: Decimal.t(),
          type_account: :corrente | :poupanca | :salario | :investimento,
          user_id: binary(),
          institution: Schema.Institution,
          created_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  @derive {Jason.Encoder, except: [:__meta__, :__struct__]}

  schema "accounts" do
    field :name, :string
    field :num_account, :string
    field :description, :string
    field :initial_amount_value, :decimal
    field :type_account, Types.TypeAccount

    field :user_id, :binary_id
    belongs_to :institution, Schema.Institution

    timestamps(
      inserted_at: :created_at,
      updated_at: :updated_at,
      type: :utc_datetime
    )
  end

  def create_changeset(%__MODULE__{} = struct, params) do
    options_fields = [
      :description,
      :institution_id
    ]

    fields_required = [
      :name,
      :num_account,
      :initial_amount_value,
      :type_account,
      :user_id
    ]

    struct
    |> cast(params, fields_required ++ options_fields)
    |> foreign_key_constraint(:intituition_id)
    |> foreign_key_constraint(:user_id)
    |> validate_required(fields_required)
    |> validate_changeset()
  end

  defp validate_changeset(changeset) do
    changeset
    |> validate_length(:nome, min: 3, max: 80)
    |> validate_length(:num_account, min: 5, max: 20)
  end
end
