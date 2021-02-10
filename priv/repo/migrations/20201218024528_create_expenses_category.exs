defmodule MyExpenses.Repo.Migrations.CreateCategoryExpenses do
  use Ecto.Migration

  def change do
    create table(:expenses_category) do
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

    create unique_index(:expenses_category, [:id], name: :IDX_EXPENSES_CATEGORY_ID)
  end

  def down do
    drop table(:expenses_category)
  end
end
