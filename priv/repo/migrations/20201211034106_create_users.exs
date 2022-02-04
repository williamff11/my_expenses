defmodule MyExpenses.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :name, :string, size: 80, null: false
      add :email, :string, size: 180, null: false
      add :phone, :string, size: 15, null: false
      add :birth_date, :date, null: false
      add :cpf, :string, unique: true, null: false
      add :login, :string, size: 50, unique: true, null: false
      add :salt, :string, null: false
      add :password, :string, size: 200, null: false

      add :deleted_at, :utc_datetime

      timestamps(
        inserted_at: :created_at,
        updated_at: :updated_at,
        type: :utc_datetime
      )
    end

    create unique_index(:users, [:cpf, :login], name: :IDX_USERS_CPF_LOGIN)
  end

  def down do
    drop table(:users)
  end
end
