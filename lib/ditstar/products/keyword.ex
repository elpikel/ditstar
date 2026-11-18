defmodule Ditstar.Products.Keyword do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Ditstar.Products.Product

  schema "keywords" do
    belongs_to :product, Product
    field :term, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = keyword, attrs) do
    keyword
    |> cast(attrs, [:term])
    |> update_change(:term, &String.trim/1)
    |> validate_required([:term])
    |> validate_length(:term, max: 100)
    |> unique_constraint(:term,
      name: :keywords_product_id_lower_term_index,
      message: "has already been added"
    )
  end
end
