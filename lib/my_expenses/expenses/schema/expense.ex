defmodule MyExpenses.Expenses.Schema.Expense do
  @moduledoc """
  Schema das Gastos
  """
  @behaviour Access

  use Ecto.Schema

  import Ecto.Changeset

  alias MyExpenses.Accounts.Schema.Account
  alias MyExpenses.Ecto.Types
  alias MyExpenses.Expenses.Schema
  alias MyExpenses.Users.Schema.User

  @type t() :: %__MODULE__{
          description: String.t(),
          amount: Decimal.t(),
          attachment: String.t(),
          tag: String.t(),
          note: DateTime.t(),
          date_spend: Date.t(),
          payed?: boolean(),
          fix?: boolean(),
          frequency: :semanalmente | :quinzenalmente | :mensalmente | :anualmente,
          account_id: binary(),
          user_id: binary(),
          expense_category: Schema.ExpenseCategory,
          deleted_at: DateTime.t(),
          created_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @derive {Jason.Encoder, except: [:__meta__, :__struct__, :account, :user, :expense_category]}

  schema "expenses" do
    field :description, :string
    field :amount, :decimal
    field :attachment, :string
    field :date_spend, :date
    field :payed?, :boolean
    field :payment_method, Types.Atom
    field :fix?, :boolean
    field :frequency, Types.Atom
    field :tag, :string
    field :note, :string

    belongs_to :account, Account
    belongs_to :user, User
    belongs_to :expense_category, Schema.ExpenseCategory

    field :deleted_at, :utc_datetime

    timestamps(
      inserted_at: :created_at,
      updated_at: :updated_at,
      type: :utc_datetime
    )
  end

  @impl Access
  def fetch(%__MODULE__{} = struct, key), do: Map.fetch(struct, key)

  @impl Access
  def get_and_update(_, _, _) do
    raise "not implemented"
  end

  @impl Access
  def pop(_, _) do
    raise "not implemented"
  end

  @fields ~w(
    description
    amount
    date_spend
    payed?
    payment_method
    fix?
    account_id
    user_id
    expense_category_id
    tag
    attachment
    note
    frequency
  )a

  @fields_required ~w(
    description
    amount
    date_spend
    payed?
    payment_method
    fix?
    account_id
    user_id
    expense_category_id
  )a

  def create_changeset(%__MODULE__{} = struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_changeset()
  end

  def update_changeset(%__MODULE__{} = struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_changeset()
  end

  defp validate_changeset(changeset) do
    changeset
    |> validate_required(@fields_required)
    |> validate_length(:description, max: 255)
    |> validate_number(:amount, greater_than: 0)
    |> foreign_key_constraint(:expense_category_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:account_id)
  end
end
