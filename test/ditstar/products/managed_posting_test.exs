defmodule Ditstar.Products.ManagedPostingTest do
  use Ditstar.DataCase, async: false

  import Ditstar.AccountsFixtures
  import Ditstar.ProductsFixtures

  alias Ditstar.Products
  alias Ditstar.Products.Product

  test "with managed posting enabled a Product can default to a Managed Account poster" do
    previous_setting = Application.fetch_env!(:ditstar, :managed_posting_enabled)
    Application.put_env(:ditstar, :managed_posting_enabled, true)
    on_exit(fn -> Application.put_env(:ditstar, :managed_posting_enabled, previous_setting) end)
    scope = user_scope_fixture()

    product = product_fixture(scope, %{default_poster: "managed_account"})

    assert %Product{default_poster: :managed_account} = Products.get_product(scope, product.id)
  end

  test "with managed posting disabled a Managed Account default poster is rejected" do
    previous_setting = Application.fetch_env!(:ditstar, :managed_posting_enabled)
    Application.put_env(:ditstar, :managed_posting_enabled, false)
    on_exit(fn -> Application.put_env(:ditstar, :managed_posting_enabled, previous_setting) end)
    scope = user_scope_fixture()

    {:error, changeset} =
      Products.save_product(scope, %Product{}, %{
        name: "Invoicely",
        default_poster: "managed_account"
      })

    assert %{default_poster: ["is invalid"]} = errors_on(changeset)
  end
end
