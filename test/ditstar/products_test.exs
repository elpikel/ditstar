defmodule Ditstar.ProductsTest do
  use Ditstar.DataCase, async: true

  import Ditstar.AccountsFixtures
  import Ditstar.ProductsFixtures

  alias Ditstar.Products
  alias Ditstar.Products.Product

  test "saving a new Product stores its fields and watch lists in the User's Account" do
    scope = user_scope_fixture()

    {:ok, product} =
      Products.save_product(scope, %Product{}, %{
        "name" => "Invoicely",
        "website" => "https://invoicely.example",
        "description" => "Invoicing for EU freelancers",
        "watched_subreddits" => %{"0" => %{"name" => "freelance"}},
        "keywords" => %{"0" => %{"term" => "invoicing"}, "1" => %{"term" => "EU VAT"}},
        "competitors" => %{"0" => %{"name" => "Billcraft"}}
      })

    assert %Product{
             name: "Invoicely",
             website: "https://invoicely.example",
             description: "Invoicing for EU freelancers",
             default_poster: :own_account,
             watched_subreddits: [%{name: "freelance"}],
             keywords: [%{term: "invoicing"}, %{term: "EU VAT"}],
             competitors: [%{name: "Billcraft"}]
           } = Products.get_product(scope, product.id)

    assert product.account_id == scope.account.id
  end

  test "a Watched Subreddit, Keyword and Competitor added to a saved Product are saved with it" do
    scope = user_scope_fixture()
    product = product_fixture(scope, %{"keywords" => %{"0" => %{"term" => "crm"}}})
    [keyword] = product.keywords

    {:ok, _product} =
      Products.save_product(scope, product, %{
        "keywords" => %{
          "0" => %{"id" => to_string(keyword.id), "term" => "crm"},
          "1" => %{"term" => "pipeline"}
        },
        "watched_subreddits" => %{"0" => %{"name" => "sales"}},
        "competitors" => %{"0" => %{"name" => "Pipedrive"}}
      })

    assert %Product{
             keywords: [%{term: "crm"}, %{term: "pipeline"}],
             watched_subreddits: [%{name: "sales"}],
             competitors: [%{name: "Pipedrive"}]
           } = Products.get_product(scope, product.id)
  end

  test "a Keyword dropped from a saved Product is no longer on it after save" do
    scope = user_scope_fixture()

    product =
      product_fixture(scope, %{
        "keywords" => %{"0" => %{"term" => "crm"}, "1" => %{"term" => "pipeline"}}
      })

    [crm, pipeline] = product.keywords

    {:ok, _product} =
      Products.save_product(scope, product, %{
        "keywords" => %{
          "0" => %{"id" => to_string(crm.id), "term" => "crm"},
          "1" => %{"id" => to_string(pipeline.id), "term" => "pipeline"}
        },
        "keywords_drop" => ["0"]
      })

    assert %Product{keywords: [%{term: "pipeline"}]} = Products.get_product(scope, product.id)
  end

  test "a Watched Subreddit entered as r/SaaS is stored as saas" do
    scope = user_scope_fixture()

    product = product_fixture(scope, %{"watched_subreddits" => %{"0" => %{"name" => " r/SaaS "}}})

    assert %Product{watched_subreddits: [%{name: "saas"}]} =
             Products.get_product(scope, product.id)
  end

  test "listing Products returns only the Scope's Account's Products, oldest first" do
    scope = user_scope_fixture()
    other_scope = user_scope_fixture()
    first = product_fixture(scope)
    second = product_fixture(scope)
    product_fixture(other_scope)

    assert [%Product{id: first_id}, %Product{id: second_id}] = Products.list_products(scope)
    assert [first_id, second_id] == [first.id, second.id]
  end

  test "adding a Keyword that differs only in case from a saved one errors on that entry and saves nothing" do
    scope = user_scope_fixture()
    product = product_fixture(scope, %{"keywords" => %{"0" => %{"term" => "crm"}}})
    [keyword] = product.keywords

    {:error, changeset} =
      Products.save_product(scope, product, %{
        "name" => "Renamed",
        "keywords" => %{
          "0" => %{"id" => to_string(keyword.id), "term" => "crm"},
          "1" => %{"term" => "CRM"}
        }
      })

    assert [%{errors: []}, duplicate] = changeset.changes.keywords
    assert %{term: ["has already been added"]} = errors_on(duplicate)

    assert %Product{name: name, keywords: [%{term: "crm"}]} =
             Products.get_product(scope, product.id)

    assert name == product.name
  end

  test "two new Keywords that differ only in case in one save are rejected and nothing is saved" do
    scope = user_scope_fixture()

    {:error, changeset} =
      Products.save_product(scope, %Product{}, %{
        "name" => "Invoicely",
        "keywords" => %{"0" => %{"term" => "crm"}, "1" => %{"term" => " CRM "}}
      })

    assert [%{errors: []}, duplicate] = changeset.changes.keywords
    assert %{term: ["has already been added"]} = errors_on(duplicate)
    assert Products.list_products(scope) == []
  end

  test "a Product without a name is rejected and nothing is saved" do
    scope = user_scope_fixture()

    {:error, changeset} = Products.save_product(scope, %Product{}, %{"name" => "  "})

    assert %{name: ["can't be blank"]} = errors_on(changeset)
    assert Products.list_products(scope) == []
  end

  test "a blank Keyword is rejected" do
    scope = user_scope_fixture()

    {:error, changeset} =
      Products.save_product(scope, %Product{}, %{
        "name" => "Invoicely",
        "keywords" => %{"0" => %{"term" => " "}}
      })

    assert %{keywords: [%{term: ["can't be blank"]}]} = errors_on(changeset)
  end

  test "a Watched Subreddit that is not a valid subreddit name is rejected" do
    scope = user_scope_fixture()

    {:error, changeset} =
      Products.save_product(scope, %Product{}, %{
        "name" => "Invoicely",
        "watched_subreddits" => %{"0" => %{"name" => "r/small business!"}}
      })

    assert %{watched_subreddits: [%{name: ["is not a valid subreddit name"]}]} =
             errors_on(changeset)
  end

  test "a Product in another Account is not found" do
    product = product_fixture(user_scope_fixture())
    scope = user_scope_fixture()

    assert Products.get_product(scope, product.id) == nil
  end

  test "a Product id that is not an id is not found" do
    scope = user_scope_fixture()

    assert Products.get_product(scope, "not-an-id") == nil
  end

  test "a Product in another Account cannot be updated through this Scope" do
    owner_scope = user_scope_fixture()
    product = product_fixture(owner_scope)
    scope = user_scope_fixture()

    assert Products.save_product(scope, product, %{name: "Hijacked"}) == {:error, :not_found}
    assert %Product{name: name} = Products.get_product(owner_scope, product.id)
    assert name == product.name
  end

  test "a new Product is saved in the Scope's Account even when attrs name another Account" do
    scope = user_scope_fixture()
    other_scope = user_scope_fixture()

    {:ok, product} =
      Products.save_product(scope, %Product{}, %{
        name: "Invoicely",
        account_id: other_scope.account.id
      })

    assert product.account_id == scope.account.id
  end
end
