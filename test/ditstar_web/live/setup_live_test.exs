defmodule DitstarWeb.Live.SetupLiveTest do
  use DitstarWeb.ConnCase, async: true

  import Ditstar.AccountsFixtures
  import Ditstar.ProductsFixtures
  import Phoenix.LiveViewTest

  alias Ditstar.Products
  alias Ditstar.Products.Product

  test "an account with no products sees the three empty setup cards", %{conn: conn} do
    user = user_fixture()

    {:ok, view, _html} = conn |> log_in_user(user) |> live(~p"/app/setup")

    assert has_element?(view, "#setup-product h2", "Your product")
    assert has_element?(view, "#setup-where-to-look h2", "Where to look")
    assert has_element?(view, "#setup-who-posts h2", "Who posts by default")
    assert has_element?(view, "#product_name[placeholder='[YOUR PRODUCT]']:not([value])")
    refute has_element?(view, "#setup-where-to-look input[type='text']")
    assert has_element?(view, "#app-sidebar nav a[href='#{~p"/app/setup"}'][aria-current='page']", "Setup")
  end

  test "saving a filled-in setup stores the product and its lists in the account and opens the inbox",
       %{conn: conn} do
    user = user_fixture()
    scope = user_scope_fixture(user)
    conn = log_in_user(conn, user)
    {:ok, view, _html} = live(conn, ~p"/app/setup")

    view
    |> form("#setup-form")
    |> render_change(%{
      "product" => %{"watched_subreddits_sort" => ["new"], "keywords_sort" => ["new"], "competitors_sort" => ["new"]}
    })

    view
    |> form("#setup-form",
      product: %{
        name: "Invoicely",
        website: "https://invoicely.example",
        description: "Invoicing for freelancers",
        watched_subreddits: %{"0" => %{name: "freelance"}},
        keywords: %{"0" => %{term: "invoicing"}},
        competitors: %{"0" => %{name: "Billr"}}
      }
    )
    |> render_submit()

    assert has_element?(view, "#setup-current-product-form[phx-trigger-action]")
    conn = view |> form("#setup-current-product-form") |> follow_trigger_action(conn)
    assert redirected_to(conn) == ~p"/app"

    assert [%Product{id: product_id}] = Products.list_products(scope)
    assert get_session(conn, :current_product_id) == product_id

    assert %Product{
             name: "Invoicely",
             website: "https://invoicely.example",
             description: "Invoicing for freelancers",
             watched_subreddits: [%{name: "freelance"}],
             keywords: [%{term: "invoicing"}],
             competitors: [%{name: "Billr"}]
           } = Products.get_product(scope, product_id)
  end

  test "the dashed add chip adds a keyword chip that is saved with the product", %{conn: conn} do
    user = user_fixture()
    scope = user_scope_fixture(user)
    product = product_fixture(scope, %{"keywords" => [%{"term" => "invoicing"}]})
    {:ok, view, _html} = conn |> log_in_user(user) |> live(~p"/app/setup")

    assert has_element?(view, "button[name='product[keywords_sort][]'][value='new']", "+ Add keyword")

    view
    |> form("#setup-form")
    |> render_change(%{"product" => %{"keywords_sort" => ["0", "new"]}})

    assert has_element?(view, "input[name='product[keywords][1][term]']")
    assert has_element?(view, "label[for='product_keywords_1_term']", "Keyword")

    view
    |> form("#setup-form", product: %{keywords: %{"1" => %{term: "EU VAT"}}})
    |> render_submit()

    assert %Product{keywords: [%{term: "invoicing"}, %{term: "EU VAT"}]} = Products.get_product(scope, product.id)
  end

  test "removing a keyword chip with its remove button and saving deletes the keyword", %{conn: conn} do
    user = user_fixture()
    scope = user_scope_fixture(user)
    product = product_fixture(scope, %{"keywords" => [%{"term" => "crm"}, %{"term" => "invoicing"}]})
    {:ok, view, _html} = conn |> log_in_user(user) |> live(~p"/app/setup")

    assert has_element?(view, "button[name='product[keywords_drop][]'][value='0'][aria-label='Remove crm']")

    view
    |> form("#setup-form")
    |> render_change(%{"product" => %{"keywords_drop" => ["0"]}})

    refute has_element?(view, "input[value='crm']")

    assert {:error, {:live_redirect, %{to: "/app"}}} = view |> form("#setup-form") |> render_submit()

    assert %Product{keywords: [%{term: "invoicing"}]} = Products.get_product(scope, product.id)
  end

  test "a subreddit entered as r/SaaS is saved as saas", %{conn: conn} do
    user = user_fixture()
    scope = user_scope_fixture(user)
    product = product_fixture(scope)
    {:ok, view, _html} = conn |> log_in_user(user) |> live(~p"/app/setup")

    view
    |> form("#setup-form")
    |> render_change(%{"product" => %{"watched_subreddits_sort" => ["new"]}})

    view
    |> form("#setup-form", product: %{watched_subreddits: %{"0" => %{name: "r/SaaS"}}})
    |> render_submit()

    assert %Product{watched_subreddits: [%{name: "saas"}]} = Products.get_product(scope, product.id)
  end

  test "adding a keyword the product already has shows an error on that chip and saves nothing",
       %{conn: conn} do
    user = user_fixture()
    scope = user_scope_fixture(user)
    product = product_fixture(scope, %{"keywords" => [%{"term" => "crm"}]})
    {:ok, view, _html} = conn |> log_in_user(user) |> live(~p"/app/setup")

    view
    |> form("#setup-form")
    |> render_change(%{"product" => %{"keywords_sort" => ["0", "new"]}})

    view
    |> form("#setup-form", product: %{name: "Renamed", keywords: %{"1" => %{term: "CRM"}}})
    |> render_submit()

    assert has_element?(view, "input[name='product[keywords][1][term]'][aria-invalid='true']")
    assert has_element?(view, "#product_keywords_1_term-error", "has already been added")
    refute has_element?(view, "input[name='product[keywords][0][term]'][aria-invalid]")

    assert %Product{name: name, keywords: [%{term: "crm"}]} = Products.get_product(scope, product.id)
    assert name == product.name
  end

  test "saving without a product name shows an error and saves nothing", %{conn: conn} do
    user = user_fixture()
    scope = user_scope_fixture(user)
    {:ok, view, _html} = conn |> log_in_user(user) |> live(~p"/app/setup")

    view
    |> form("#setup-form", product: %{name: "", website: "https://invoicely.example"})
    |> render_submit()

    assert has_element?(view, "#product_name[aria-invalid='true']")
    assert has_element?(view, "#product_name-error", "can't be blank")
    assert Products.list_products(scope) == []
  end

  test "a new product defaults to You post", %{conn: conn} do
    user = user_fixture()

    {:ok, view, _html} = conn |> log_in_user(user) |> live(~p"/app/setup")

    assert has_element?(view, "#setup-who-posts button[aria-pressed='true']", "You post")
    assert has_element?(view, "input[type='hidden'][name='product[default_poster]'][value='own_account']")
  end

  test "with managed posting disabled the Ditstar posting choice is not shown", %{conn: conn} do
    user = user_fixture()

    {:ok, view, _html} = conn |> log_in_user(user) |> live(~p"/app/setup")

    assert has_element?(view, "#setup-who-posts button", "You post")
    refute has_element?(view, "#setup-who-posts button", "Ditstar posts, labelled")
  end

  test "Add product opens empty setup cards and saving creates a second product", %{conn: conn} do
    user = user_fixture()
    scope = user_scope_fixture(user)
    first_product = product_fixture(scope, %{"keywords" => [%{"term" => "crm"}]})
    conn = log_in_user(conn, user)
    {:ok, view, _html} = live(conn, ~p"/app/setup/new")

    assert has_element?(view, "#product_name:not([value])")
    refute has_element?(view, "#setup-where-to-look input[type='text']")

    view
    |> form("#setup-form", product: %{name: "Second product"})
    |> render_submit()

    conn = view |> form("#setup-current-product-form") |> follow_trigger_action(conn)

    assert redirected_to(conn) == ~p"/app"
    assert [%Product{id: first_id}, %Product{id: second_id, name: "Second product"}] = Products.list_products(scope)
    assert first_id == first_product.id
    assert get_session(conn, :current_product_id) == second_id
  end

  test "setup never opens or saves a product from another account", %{conn: conn} do
    user = user_fixture()
    scope = user_scope_fixture(user)
    other_scope = user_scope_fixture()
    other_product = product_fixture(other_scope, %{"keywords" => [%{"term" => "crm"}]})

    {:ok, view, _html} =
      conn
      |> log_in_user(user)
      |> put_session(:current_product_id, other_product.id)
      |> live(~p"/app/setup?product_id=#{other_product.id}")

    assert has_element?(view, "#product_name:not([value])")
    refute has_element?(view, "#setup-form input[value='crm']")

    view
    |> form("#setup-form", product: %{name: "Mine"})
    |> render_submit()

    assert [%Product{name: "Mine"}] = Products.list_products(scope)
    assert %Product{name: other_name, keywords: [%{term: "crm"}]} = Products.get_product(other_scope, other_product.id)
    assert other_name == other_product.name
  end
end
