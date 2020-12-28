defmodule MyExpenses.Repo.Migrations.CreateCategoryDebts do
  use Ecto.Migration

  def change do
    create table(:category_debts) do
      add(:name, :string, size: 80)
      add(:description, :string, size: 255)
      add(:icon, :string)
      add(:color, :string)

      timestamps(
        inserted_at: :created_at,
        updated_at: :updated_at,
        type: :utc_datetime
      )
    end
    create unique_index(:category_debts, [:id], name: :IDX_CATEGORY_DEBTS_ID)
  end
  def down do
    drop table(:category_debts)
  end
end
