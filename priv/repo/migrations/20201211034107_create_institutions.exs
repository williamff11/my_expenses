defmodule MyExpenses.Repo.Migrations.CreateBanks do
  use Ecto.Migration

  def change do
    create table(:institutions, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :logo, :string
      add :name, :string
      add :legal_name, :string
    end
  end
end
