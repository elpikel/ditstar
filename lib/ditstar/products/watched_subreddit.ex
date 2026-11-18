defmodule Ditstar.Products.WatchedSubreddit do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Ditstar.Products.Product

  schema "watched_subreddits" do
    belongs_to :product, Product
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = watched_subreddit, attrs) do
    watched_subreddit
    |> cast(attrs, [:name])
    |> update_change(:name, &normalize_name/1)
    |> validate_required([:name])
    |> validate_format(:name, ~r/^[a-z0-9_]{2,21}$/, message: "is not a valid subreddit name")
    |> unique_constraint(:name,
      name: :watched_subreddits_product_id_lower_name_index,
      message: "has already been added"
    )
  end

  defp normalize_name(name) do
    name
    |> String.trim()
    |> String.replace(~r{^/?r/}i, "")
    |> String.downcase()
  end
end
