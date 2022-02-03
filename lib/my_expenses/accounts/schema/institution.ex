defmodule MyExpenses.Accounts.Schema.Institution do
  @moduledoc """
  Módulo responsável pelas intituições bancárias do sistema.
  """

  use Ecto.Schema

  @type t() :: %__MODULE__{
          logo: String.t(),
          name: String.t(),
          legal_name: String.t()
        }
  @derive {Jason.Encoder, except: [:__meta__, :__struct__]}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "institutions" do
    field :logo, :string
    field :name, :string
    field :legal_name, :string
  end
end
