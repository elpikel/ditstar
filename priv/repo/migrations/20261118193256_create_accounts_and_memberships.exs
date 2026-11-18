defmodule Ditstar.Repo.Migrations.CreateAccountsAndMemberships do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      timestamps(type: :utc_datetime)
    end

    create table(:account_memberships, primary_key: false) do
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:account_memberships, [:account_id, :user_id])
    create index(:account_memberships, [:user_id])
  end
end
