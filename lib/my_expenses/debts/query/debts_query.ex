defmodule MyExpenses.Debts.Query.DebtsQuery do
  @moduledoc false

  import Ecto.Query

  alias MyExpenses.Debts.Schema

  def get_category_debts do
    from(cat_debt in Schema.CategoryDebts)
  end
end
