defmodule DitstarWeb.Live.SetupLive.ManagedPostingTest do
  use DitstarWeb.ConnCase, async: false

  import Ditstar.AccountsFixtures
  import Phoenix.LiveViewTest

  alias Ditstar.Products
  alias Ditstar.Products.Product

  test "with managed posting enabled, picking Ditstar posts and saving defaults the product to a Managed Account",
       %{conn: conn} do
    previous_setting = Application.fetch_env!(:ditstar, :managed_posting_enabled)
    Application.put_env(:ditstar, :managed_posting_enabled, true)
    on_exit(fn -> Application.put_env(:ditstar, :managed_posting_enabled, previous_setting) end)
    user = user_fixture()
    scope = user_scope_fixture(user)
    {:ok, view, _html} = conn |> log_in_user(user) |> live(~p"/app/setup")

    view
    |> element("#setup-who-posts button", "Ditstar posts, labelled")
    |> render_click()

    assert has_element?(view, "#setup-who-posts button[aria-pressed='true']", "Ditstar posts, labelled")
    assert has_element?(view, "#setup-who-posts button[aria-pressed='false']", "You post")

    view
    |> form("#setup-form", product: %{name: "Invoicely"})
    |> render_submit()

    assert [%Product{default_poster: :managed_account}] = Products.list_products(scope)
  end
end
