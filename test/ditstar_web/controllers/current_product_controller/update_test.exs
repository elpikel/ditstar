defmodule DitstarWeb.Controllers.CurrentProductController.UpdateTest do
  use DitstarWeb.ConnCase, async: true

  import Ditstar.AccountsFixtures
  import Ditstar.ProductsFixtures

  test "switching to the second product makes it the current product and opens Setup", %{conn: conn} do
    user = user_fixture()
    scope = user_scope_fixture(user)
    _first_product = product_fixture(scope)
    second_product = product_fixture(scope)

    conn =
      conn
      |> log_in_user(user)
      |> put(~p"/app/current-product", %{"product_id" => second_product.id})

    assert redirected_to(conn) == ~p"/app/setup"
    assert get_session(conn, :current_product_id) == second_product.id
  end

  test "making a product current after creating it in Setup opens the Inbox", %{conn: conn} do
    user = user_fixture()
    scope = user_scope_fixture(user)
    _first_product = product_fixture(scope)
    created_product = product_fixture(scope)

    conn =
      conn
      |> log_in_user(user)
      |> put(~p"/app/current-product", %{"product_id" => created_product.id, "after" => "inbox"})

    assert redirected_to(conn) == ~p"/app"
    assert get_session(conn, :current_product_id) == created_product.id
  end

  test "switching to a product in another account is not found and leaves the current product unchanged",
       %{conn: conn} do
    user = user_fixture()
    current_product = user |> user_scope_fixture() |> product_fixture()
    other_account_product = product_fixture(user_scope_fixture())

    conn =
      conn
      |> log_in_user(user)
      |> put_session(:current_product_id, current_product.id)
      |> put(~p"/app/current-product", %{"product_id" => other_account_product.id})

    assert html_response(conn, 404)
    assert get_session(conn, :current_product_id) == current_product.id
  end

  test "a visitor who is not signed in is redirected to the sign-in page", %{conn: conn} do
    product = product_fixture(user_scope_fixture())

    conn = put(conn, ~p"/app/current-product", %{"product_id" => product.id})

    assert redirected_to(conn) == ~p"/users/log-in"
  end
end
