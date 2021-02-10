defmodule MyExpenses.Expenses.Schema.Expense do
  @moduledoc """
  Schema das Gastos
  """
  @behaviour Access

  use Ecto.Schema

  import Ecto.Changeset

  alias MyExpenses.Ecto.Types
  alias MyExpenses.Expenses.Schema

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
          account_id: binary(),
          user_id: binary(),
          expense_category: Schema.ExpenseCategory,
          deleted_at: DateTime.t(),
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
    field :account_id, :binary_id
    field :user_id, :binary_id

    belongs_to :expense_category, Schema.ExpenseCategory

    field :deleted_at, :utc_datetime

    timestamps(
      inserted_at: :created_at,
      updated_at: :updated_at,
      type: :utc_datetime
    )
  end

  @impl Access
  def fetch(%__MODULE__{} = struct, key) do
    Map.fetch(struct, key)
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
      :account_id,
      :user_id,
      :expense_category_id
    ]

    struct
    |> cast(params, fields_required ++ options_fields)
    |> validate_changeset()
  end

  def update_changeset(%__MODULE__{} = struct, params) do
    fields = [
      :description,
      :amount,
      :date_spend,
      :payed,
      :fix,
      :account_id,
      :tag,
      :attachment,
      :note,
      :frequency,
      :expense_category_id
    ]

    struct
    |> cast(params, fields)
    |> validate_changeset()
  end

  defp validate_changeset(changeset) do
    fields_required = [
      :description,
      :amount,
      :date_spend,
      :payed,
      :fix,
      :account_id,
      :user_id,
      :expense_category_id
    ]

    changeset
    |> validate_required(fields_required)
    |> validate_length(:description, max: 255)
    |> validate_number(:amount, greater_than: 0)
    |> foreign_key_constraint(:expense_category_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:account_id)
  end
end
