defmodule MyExpenses.Expenses.Schema.ExpenseCategory do
  @moduledoc """
  Módulo responsável por gerenciar as categoria de gastos do sistema
  """
  @behaviour Access

  use Ecto.Schema

  import Ecto.Changeset

  alias MyExpenses.Expenses.Schema

  @type t() :: %__MODULE__{
          id: non_neg_integer(),
          name: String.t(),
          description: String.t(),
          icon: String.t(),
          color: String.t(),
          created_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @derive {Jason.Encoder, except: [:__meta__, :__struct__, :expense]}

  schema "expenses_category" do
    field(:name, :string)
    field(:description, :string)
    field(:icon, :string)
    field(:color, :string)

    has_many(:expense, Schema.Expense)

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

  def changeset(%__MODULE__{} = struct, params) do
    fields = [
      :name,
      :description,
      :icon,
      :color
    ]

    struct
    |> cast(params, fields)
    |> validate_required(fields)
    |> validate_length(:name, min: 3, max: 80)
    |> unique_constraint(:name)
  end
end
