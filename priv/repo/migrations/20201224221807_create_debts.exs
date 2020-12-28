defmodule MyExpenses.Repo.Migrations.CreateDebts do
  use Ecto.Migration

  def change do
    create table(:debts, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)
      add(:description, :string, size: 255)
      add(:amount, :decimal)
      add(:attachment, :string, null: true)
      add(:tag, :string, null: true)
      add(:note, :string, null: true)
      add(:date_debt, :date, null: false)
      add(:payed, :boolean, null: false)

      add(:conta_id, :uuid)
      add(:user_id, :uuid)
      add(:category_debts_id, references(:category_debts))

      timestamps(
        inserted_at: :created_at,
        updated_at: :updated_at,
        type: :utc_datetime
      )
    end
    create unique_index(:debts,
    [
    :id,
    :conta_id,
    :user_id,
    :category_debts_id
    ])
  end

  def down do
    drop table(:debts)
  end
end
