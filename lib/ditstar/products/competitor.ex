defmodule Ditstar.Products.Competitor do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Ditstar.Products.Product

  schema "competitors" do
    belongs_to :product, Product
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = competitor, attrs) do
    competitor
    |> cast(attrs, [:name])
    |> update_change(:name, &String.trim/1)
    |> validate_required([:name])
    |> validate_length(:name, max: 100)
    |> unique_constraint(:name,
      name: :competitors_product_id_lower_name_index,
      message: "has already been added"
    )
  end
end
