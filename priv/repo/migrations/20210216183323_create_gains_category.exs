defmodule MyExpenses.Repo.Migrations.CreateWinningsCategory do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:gains_category) do
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

    create unique_index(:gains_category, [:id], name: :IDX_GAINS_CATEGORY_ID)

    create unique_index(:gains_category, [:name])
  end

  def down do
    drop table(:gains_category)
  end
end
