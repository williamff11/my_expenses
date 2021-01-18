defmodule MyExpenses.Repo.Migrations.CreateBanks do
  use Ecto.Migration

  def change do
    create table(:institutions) do
      add(:logo, :string)
      add(:name, :string)
      add(:legal_name, :string)
    end
  end
end
