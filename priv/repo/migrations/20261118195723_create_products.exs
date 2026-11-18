defmodule Ditstar.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :website, :text
      add :description, :text
      add :default_poster, :string, null: false, default: "own_account"

      timestamps(type: :utc_datetime)
    end

    create index(:products, [:account_id])

    create table(:keywords) do
      add :product_id, references(:products, on_delete: :delete_all), null: false
      add :term, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:keywords, [:product_id, "lower(term)"],
             name: :keywords_product_id_lower_term_index
           )

    create table(:watched_subreddits) do
      add :product_id, references(:products, on_delete: :delete_all), null: false
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:watched_subreddits, [:product_id, "lower(name)"],
             name: :watched_subreddits_product_id_lower_name_index
           )

    create table(:competitors) do
      add :product_id, references(:products, on_delete: :delete_all), null: false
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:competitors, [:product_id, "lower(name)"],
             name: :competitors_product_id_lower_name_index
           )
  end
end
