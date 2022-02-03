defmodule MyExpenses.Gains.Schema.GainCategory do
  @moduledoc """
  Módulo responsável por gerenciar as categoria de ganhos do sistema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias MyExpenses.Gains.Schema

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

  @derive {Jason.Encoder, except: [:__meta__, :__struct__, :gain]}

  schema "gains_category" do
    field :name, :string
    field :description, :string
    field :icon, :string
    field :color, :string

    has_many :gain, Schema.Gain

    timestamps(
      inserted_at: :created_at,
      updated_at: :updated_at,
      type: :utc_datetime
    )
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
