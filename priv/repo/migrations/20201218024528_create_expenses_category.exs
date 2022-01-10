defmodule MyExpenses.Repo.Migrations.CreateCategoryExpenses do
  use Ecto.Migration

  def change do
    create table(:expenses_category, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :name, :string, size: 80
      add :description, :string, size: 255
      add :icon, :string
      add :color, :string

      timestamps(
        inserted_at: :created_at,
        updated_at: :updated_at,
        type: :utc_datetime
      )
    end
  end

  def down do
    drop table(:expenses_category)
  end
end
