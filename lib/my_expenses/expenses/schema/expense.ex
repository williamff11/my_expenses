defmodule MyExpenses.Expenses.Schema.Expense do
  @moduledoc """
  Schema das Gastos
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias MyExpenses.Expenses.Schema
  alias MyExpenses.Ecto.Types

  @type t() :: %__MODULE__{
          description: String.t(),
          amount: Decimal.t(),
          attachment: String.t(),
          tag: String.t(),
          note: DateTime.t(),
          date_spend: Date.t(),
          payed: boolean(),
          fix: boolean(),
          frequency: :semanalmente | :quinzenalmente | :mensalmente | :anualmente,
          conta_id: binary(),
          user_id: binary(),
          expense_category: Schema.ExpenseCategory,
          created_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  @derive {Jason.Encoder, except: [:__meta__, :__struct__]}

  schema "expenses" do
    field :description, :string
    field :amount, :decimal
    field :attachment, :string
    field :date_spend, :date
    field :payed, :boolean
    field :fix, :boolean
    field :frequency, Types.Atom
    field :tag, :string
    field :note, :string
    field :conta_id, :binary_id
    field :user_id, :binary_id

    belongs_to :expense_category, Schema.ExpenseCategory

    timestamps(
      inserted_at: :created_at,
      updated_at: :updated_at,
      type: :utc_datetime
    )
  end

  def create_changeset(%__MODULE__{} = struct, params) do
    options_fields = [
      :tag,
      :attachment,
      :note,
      :frequency
    ]

    fields_required = [
      :description,
      :amount,
      :date_spend,
      :payed,
      :fix,
      :conta_id,
      :user_id,
      :expense_category_id
    ]

    struct
    |> cast(params, fields_required ++ options_fields)
    |> foreign_key_constraint(:expense_category_id)
    |> validate_required(fields_required)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:conta_id)
    |> validate_changeset()
  end

  defp validate_changeset(changeset) do
    changeset
    |> validate_length(:description, max: 255)
    |> validate_number(:amount, greater_than: 0)
  end
end
