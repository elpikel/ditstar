defmodule DitstarWeb.CurrentProduct do
  @moduledoc """
  Assigns the Current Product and the Account's Products to app LiveViews.

  The Current Product is the session's `current_product_id` when it names a
  Product in the signed-in User's Account; otherwise it is the Account's first
  Product, or nil when the Account has none.

      live_session :app,
        on_mount: [
          {DitstarWeb.UserAuth, :require_authenticated},
          {DitstarWeb.CurrentProduct, :assign_current_product}
        ]
  """

  import Phoenix.Component, only: [assign: 2]

  alias Ditstar.Products
  alias Ditstar.Products.Product

  def on_mount(:assign_current_product, _params, session, socket) do
    products = Products.list_products(socket.assigns.current_scope)

    {:cont,
     assign(socket,
       products: products,
       current_product: current_product(products, session["current_product_id"])
     )}
  end

  defp current_product(products, session_product_id) do
    Enum.find(products, List.first(products), fn %Product{id: id} -> id == session_product_id end)
  end
end
