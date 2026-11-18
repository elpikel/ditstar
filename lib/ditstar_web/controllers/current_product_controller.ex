defmodule DitstarWeb.CurrentProductController do
  use DitstarWeb, :controller

  alias Ditstar.Products
  alias Ditstar.Products.Product
  alias DitstarWeb.ErrorHTML

  def update(conn, %{"product_id" => product_id, "after" => "inbox"}) do
    make_current(conn, product_id, ~p"/app")
  end

  def update(conn, %{"product_id" => product_id}) do
    make_current(conn, product_id, ~p"/app/setup")
  end

  defp make_current(conn, product_id, redirect_path) do
    case Products.get_product(conn.assigns.current_scope, product_id) do
      %Product{id: id} ->
        conn
        |> put_session(:current_product_id, id)
        |> redirect(to: redirect_path)

      nil ->
        conn
        |> put_status(:not_found)
        |> put_root_layout(false)
        |> put_view(html: ErrorHTML)
        |> render(:"404")
    end
  end
end
