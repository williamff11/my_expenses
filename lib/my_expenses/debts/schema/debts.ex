defmodule MyExpenses.Debts.Schema.Debts do
  @moduledoc """
  Schema das dívidas
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias MyExpenses.Debts.Schema

  @type t() :: %__MODULE__{
          description: String.t(),
          amount: Decimal.t(),
          attachment: String.t(),
          tag: String.t(),
          note: DateTime.t(),
          date_debt: Date.t(),
          payed: boolean(),
          conta_id: binary(),
          user_id: binary(),
          category_debts: Schema.CategoryDebts,
          created_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  @derive {Jason.Encoder, except: [:__meta__, :__struct__]}

  schema "debts" do
    field :description, :string
    field :amount, :decimal
    field :attachment, :string
    field :date_debt, :date
    field :payed, :boolean
    field :tag, :string
    field :note, :string
    field :conta_id, :binary_id
    field :user_id, :binary_id

    belongs_to :category_debts, Schema.CategoryDebts

    timestamps(
      inserted_at: :created_at,
      updated_at: :updated_at,
      type: :utc_datetime
    )
  end

  def create_changeset(%__MODULE__{} = struct, params) do
    options_fields = [
      :tag,
      :note
    ]

    fields_required = [
      :description,
      :amount,
      :date_debt,
      :payed,
      :conta_id,
      :user_id,
      :category_debts_id
    ]

    struct
    |> cast(params, fields_required ++ options_fields)
    |> assoc_constraint(:category_debts_id)
    |> validate_required(fields_required)
    |> validate_changeset()
  end

  defp validate_changeset(changeset) do
    changeset
    |> validate_length(:description, max: 255)
    |> validate_number(:amount, greater_than: 0)
    |> validate_length(:phone, min: 10, max: 15)
    |> validate_length(:cpf, min: 11, max: 14)
  end
end
