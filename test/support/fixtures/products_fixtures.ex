defmodule Ditstar.ProductsFixtures do
  @moduledoc """
  Test helpers that create Products in a Scope's Account through the
  `Ditstar.Products` context.
  """

  alias Ditstar.Products
  alias Ditstar.Products.Product

  def unique_product_name, do: "Product #{System.unique_integer([:positive])}"

  def product_fixture(scope, attrs \\ %{}) do
    attrs =
      attrs
      |> Map.new(fn {key, value} -> {to_string(key), value} end)
      |> Map.put_new("name", unique_product_name())

    {:ok, product} = Products.save_product(scope, %Product{}, attrs)
    product
  end
end
