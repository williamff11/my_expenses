defmodule MyExpenses.Expenses do
  @moduledoc """
  Módulo responsável pela regra de negócio do contexto de gastos
  """

  alias MyExpenses.Expenses.Query.ExpensesQuery
  alias MyExpenses.Expenses.Schema

  @type expense_category_params() :: %{
          name: String.t(),
          description: String.t(),
          icon: String.t(),
          color: String.t()
        }

  @type expenses_params() :: %{
          description: String.t(),
          amount: Decimal.t(),
          attachment: String.t(),
          tag: String.t(),
          note: String.t(),
          date_spend: Date.t(),
          payed: boolean(),
          fix: boolean(),
          account_id: UUID.t(),
          user_id: UUID.t()
        }

  @type expense_category_filter_params() :: [id: non_neg_integer()]

  @type expenses_filter_params() :: %{
          user_id: UUID.t(),
          account_id: UUID.t(),
          expense_category_id: non_neg_integer()
        }

  @type callback_expense_category() ::
          {:ok, Schema.ExpenseCategory.t()} | {:error, Ecto.Changeset.t()}

  @type callback_expenses() ::
          {:ok, Schema.Expense.t()} | {:error, Ecto.Changeset.t()}

  @doc """
  Lista todas as categorias de gastos.
  """
  @spec list_expense_category() :: [Schema.ExpenseCategory.t()] | []
  def list_expense_category do
    ExpensesQuery.get_expense_categories()
    |> MyExpenses.Repo.all()
  end

  @doc """
  Lista todas os gastos que são fixos conforme os parâmetros.
  """
  @spec list_expenses_fixed_by(%{}) :: [%Schema.Expense{}] | nil
  def list_expenses_fixed_by(params \\ %{}) do
    ExpensesQuery.get_expenses_fixed_by(params)
    |> MyExpenses.Repo.all()
    |> MyExpenses.Repo.preload(:expense_category)
  end

  @doc """
  Lista todas as categorias de gastos que o usuário passado como argumento possui gastos.
  """
  @spec list_expense_category_by_user(User) :: [Schema.Expense.t()] | []
  def list_expense_category_by_user(user) do
    %{user_id: user.id}
    |> list_expenses_by()
    |> get_in([Access.all(), :expense_category])
    |> Enum.uniq()
  end

  @doc """
  Mostra a categoria de gastos pertencente ao id informado.
  """
  @spec show_expense_category(expense_category_filter_params()) ::
          Schema.ExpenseCategory.t() | nil
  def show_expense_category(category_id) do
    Schema.ExpenseCategory
    |> MyExpenses.Repo.get(category_id)
  end

  @doc """
  Cria uma nova categoria de gastos conforme os parâmetros informados.
  """
  @spec create_expense_category(expense_category_params()) :: callback_expense_category()
  def create_expense_category(params) do
    %Schema.ExpenseCategory{}
    |> Schema.ExpenseCategory.changeset(params)
    |> MyExpenses.Repo.insert()
  end

  @doc """
  Atualiza a categoria de gastos informada conforme os parâmetros informados.
  """
  @spec update_expense_category(Schema.ExpenseCategory.t(), expense_category_params()) ::
          callback_expense_category()
  def update_expense_category(%Schema.ExpenseCategory{} = expense_category, %{} = params) do
    expense_category
    |> Schema.ExpenseCategory.changeset(params)
    |> MyExpenses.Repo.update()
  end

  @doc """
  Deleta a categoria de gastos informada.
  """
  @spec delete_expense_category(expense_category_filter_params) :: callback_expense_category()
  def delete_expense_category(expense_category_id) do
    Schema.ExpenseCategory
    |> MyExpenses.Repo.get!(expense_category_id)
    |> MyExpenses.Repo.delete()
  end

  @doc """
  Retorna uma lista de gastos conforme os dados informados.

  A key user_id é obrigatória.
  """
  def list_expenses_by(params) do
    if not (:user_id in Map.keys(params)), do: raise("key user_id is required")

    params
    |> ExpensesQuery.get_expenses_by()
    |> MyExpenses.Repo.all()
    |> MyExpenses.Repo.preload(:expense_category)
  end

  @doc """
  Mostra o gasto que possui o ID informado
  """
  @spec show_expense(id: UUID.t()) :: Schema.Expense.t() | nil
  def show_expense(id) do
    ExpensesQuery.get_expenses_by(%{id: id, deleted_at: false})
    |> MyExpenses.Repo.one()
    |> MyExpenses.Repo.preload(:expense_category)
  end

  @doc """
  Cria um gasto com os dados passados como parâmetros.
  """
  @spec create_expense(Schema.ExpenseCategory.t(), expenses_params()) :: callback_expenses()
  def create_expense(%Schema.ExpenseCategory{} = expense_category, params) do
    %Schema.Expense{
      expense_category_id: expense_category.id
    }
    |> Schema.Expense.create_changeset(params)
    |> MyExpenses.Repo.insert()
  end

  @doc """
  Realiza um update no gasto informado com os dados informados passados como parâmetro
  """
  @spec update_expense(Schema.Expense.t(), expenses_params()) :: callback_expenses()
  def update_expense(%Schema.Expense{} = expense, %{} = params) do
    expense
    |> Schema.Expense.update_changeset(params)
    |> MyExpenses.Repo.update()
  end

  @doc """
  Deleta de forma lógica um gasto.
  """
  @spec delete_expense(Schema.Expense.t()) :: callback_expenses()
  def delete_expense(%Schema.Expense{} = expense) do
    deleted_at = DateTime.truncate(Timex.now(), :second)

    expense
    |> Ecto.Changeset.change(%{deleted_at: deleted_at})
    |> MyExpenses.Repo.update()
  end
end
