defmodule MyExpenses.Repo.Migrations.CreateExpenses do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:expenses, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)
      add(:description, :string, size: 255)
      add(:amount, :decimal)
      add(:attachment, :string, null: true)
      add(:tag, :string, null: true)
      add(:note, :string, null: true)
      add(:date_spend, :date, null: false)
      add(:payed, :boolean, null: false)
      add(:fix, :boolean, null: false)
      add(:frequency, :string, null: true)

      add(:conta_id, :uuid)
      add(:user_id, :uuid)
      add(:expense_category_id, references(:expenses_category))

      timestamps(
        inserted_at: :created_at,
        updated_at: :updated_at,
        type: :utc_datetime
      )
    end

    create unique_index(
             :expenses,
             [
               :id,
               :conta_id,
               :user_id,
               :expense_category_id
             ]
           )
  end

  def down do
    drop table(:expenses)
  end
end
