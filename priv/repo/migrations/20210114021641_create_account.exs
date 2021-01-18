defmodule MyExpenses.Repo.Migrations.CreateAccount do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)
      add(:name, :string, null: false, size: 80)
      add(:num_account, :string, null: false, size: 20)
      add(:description, :string, null: true)
      add(:initial_amount_value, :decimal, null: false)
      add(:type_account, :string, null: false)

      add(:user_id, :uuid)
      add(:institution_id, references(:institutions))

      timestamps(
        inserted_at: :created_at,
        updated_at: :updated_at,
        type: :utc_datetime
      )
    end
  end
end
