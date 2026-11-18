defmodule DitstarWeb.Live.CurrentProductTest do
  use DitstarWeb.ConnCase, async: true

  import Ditstar.AccountsFixtures
  import Ditstar.ProductsFixtures
  import Phoenix.LiveViewTest

  test "after switching, the switched-to product stays current on every app page", %{conn: conn} do
    user = user_fixture()
    scope = user_scope_fixture(user)
    first_product = product_fixture(scope)
    second_product = product_fixture(scope)

    conn =
      conn
      |> log_in_user(user)
      |> put(~p"/app/current-product", %{"product_id" => second_product.id})
      |> recycle()

    {:ok, inbox, _html} = live(conn, ~p"/app")
    {:ok, results, _html} = live(conn, ~p"/app/results")

    for view <- [inbox, results] do
      assert has_element?(view, "#product-switcher summary", second_product.name)
      assert has_element?(view, "#product-switcher button[aria-current='true']", second_product.name)
      assert has_element?(view, "#product-switcher button:not([aria-current])", first_product.name)
    end
  end

  test "a session whose product is in another account shows the account's first product as current",
       %{conn: conn} do
    user = user_fixture()
    scope = user_scope_fixture(user)
    first_product = product_fixture(scope)
    _second_product = product_fixture(scope)
    other_account_product = product_fixture(user_scope_fixture())

    {:ok, view, _html} =
      conn
      |> log_in_user(user)
      |> put_session(:current_product_id, other_account_product.id)
      |> live(~p"/app")

    assert has_element?(view, "#product-switcher summary", first_product.name)
    refute has_element?(view, "#product-switcher", other_account_product.name)
  end

  test "an account with no products shows the product placeholder and an Add product link", %{conn: conn} do
    user = user_fixture()

    {:ok, view, _html} = conn |> log_in_user(user) |> live(~p"/app")

    assert has_element?(view, "#product-switcher summary", "[YOUR PRODUCT]")
    assert has_element?(view, "#product-switcher a[href='#{~p"/app/setup/new"}']", "Add product")
  end
end
