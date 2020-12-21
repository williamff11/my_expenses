defmodule MyExpenses.Debts.Schema.CategoryDebts do
  @moduledoc """
  Módulo responsável por gerenciar as categoria de dívidas do sistema
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t() :: %__MODULE__{
          name: String.t(),
          description: String.t(),
          icon: String.t(),
          color: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "category_debts" do
    field(:name, :string)
    field(:description, :string)
    field(:icon, :string)
    field(:color, :string)

    timestamps()
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
  end
end
