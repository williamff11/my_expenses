defmodule MyExpenses.Gains.Schema.Gain do
  @moduledoc """
    Schema de Ganhos
  """
  @behaviour Access

  use Ecto.Schema

  import Ecto.Changeset

  alias MyExpenses.Accounts.Schema.Account
  alias MyExpenses.Ecto.Types
  alias MyExpenses.Gains.Schema
  alias MyExpenses.Users.Schema.User

  @type t() :: %__MODULE__{
          id: String.t(),
          description: String.t(),
          amount: Decimal.t(),
          date_receipt: Date.t(),
          attachment: String.t(),
          tag: String.t(),
          note: String.t(),
          fix?: boolean(),
          frequency: String.t(),
          account_id: UUID.t(),
          user_id: UUID.t(),
          gain_category: Schema.GainCategory,
          deleted_at: DateTime.t(),
          created_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @derive {Jason.Encoder, except: [:__meta__, :__struct__, :account, :user, :gain_category]}

  schema "gains" do
    field :description, :string
    field :amount, :decimal
    field :attachment, :string
    field :date_receipt, :date
    field :fix?, :boolean
    field :frequency, Types.Atom
    field :tag, :string
    field :note, :string

    belongs_to :account, Account
    belongs_to :user, User
    belongs_to :gain_category, Schema.GainCategory

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
      :date_receipt,
      :fix?,
      :account_id,
      :user_id,
      :gain_category_id
    ]

    struct
    |> cast(params, fields_required ++ options_fields)
    |> validate_changeset()
  end

  def update_changeset(%__MODULE__{} = gain, params) do
    fields = [
      :description,
      :amount,
      :date_receipt,
      :fix?,
      :account_id,
      :tag,
      :attachment,
      :note,
      :frequency,
      :gain_category_id
    ]

    gain
    |> cast(params, fields)
    |> validate_changeset()
  end

  defp validate_changeset(changeset) do
    fields_required = [
      :description,
      :amount,
      :date_receipt,
      :fix?,
      :account_id,
      :user_id,
      :gain_category_id
    ]

    changeset
    |> validate_required(fields_required)
    |> validate_length(:description, max: 255)
    |> validate_number(:amount, greater_than: 0)
    |> foreign_key_constraint(:gain_category_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:account_id)
  end
end
