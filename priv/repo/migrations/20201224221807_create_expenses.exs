defmodule MyExpenses.Repo.Migrations.CreateExpenses do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:expenses, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :description, :string, size: 255
      add :amount, :decimal
      add :attachment, :string
      add :tag, :string
      add :note, :string
      add :date_spend, :date, null: false
      add :payed?, :boolean, null: false
      add :fix?, :boolean, null: false
      add :frequency, :string
      add :payment_method, :string, null: false

      add :account_id, references(:accounts, type: :uuid)
      add :user_id, references(:users, type: :uuid)
      add :expense_category_id, references(:expenses_category, type: :uuid)

      add :deleted_at, :utc_datetime

      timestamps(
        inserted_at: :created_at,
        updated_at: :updated_at,
        type: :utc_datetime
      )
    end
  end

  def down do
    drop table(:expenses)
  end
end
