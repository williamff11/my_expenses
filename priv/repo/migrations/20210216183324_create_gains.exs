defmodule MyExpenses.Repo.Migrations.CreateEarnings do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:gains, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :description, :string, size: 255
      add :amount, :decimal
      add :date_receipt, :date, null: false
      add :attachment, :string, null: true
      add :tag, :string, null: true
      add :note, :string, null: true
      add :fix?, :boolean, null: false
      add :frequency, :string, null: true

      add :account_id, references(:accounts, type: :uuid)
      add :user_id, references(:users, type: :uuid)
      add :gain_category_id, references(:gains_category, type: :uuid)

      add :deleted_at, :utc_datetime, null: true

      timestamps(
        inserted_at: :created_at,
        updated_at: :updated_at,
        type: :utc_datetime
      )
    end
  end

  def down do
    drop table(:gains)
  end
end
