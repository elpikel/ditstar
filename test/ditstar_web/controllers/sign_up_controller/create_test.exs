defmodule DitstarWeb.Controllers.SignUpController.CreateTest do
  use DitstarWeb.ConnCase, async: true

  import Ditstar.AccountsFixtures
  import Swoosh.TestAssertions

  alias Ditstar.Accounts.Account
  alias Ditstar.Accounts.Membership
  alias Ditstar.Accounts.User
  alias Ditstar.Repo

  test "signing up with a new email creates a user, a new account and their membership",
       %{conn: conn} do
    email = unique_user_email()

    post(conn, ~p"/sign-up", %{"form" => "hero", "user" => %{"email" => email}})

    user = Repo.get_by!(User, email: email)
    membership = Repo.get_by!(Membership, user_id: user.id)
    assert Repo.get!(Account, membership.account_id)
  end

  test "signing up with a new email delivers a sign-in link to that address", %{conn: conn} do
    email = unique_user_email()

    post(conn, ~p"/sign-up", %{"form" => "hero", "user" => %{"email" => email}})

    assert_email_sent(fn sent_email ->
      assert sent_email.to == [{"", email}]
      assert sent_email.text_body =~ "/users/log-in/"
    end)
  end

  test "signing up from the hero form shows a check-your-email confirmation in its place",
       %{conn: conn} do
    conn =
      post(conn, ~p"/sign-up", %{"form" => "hero", "user" => %{"email" => unique_user_email()}})

    assert redirected_to(conn) == ~p"/"

    document = conn |> recycle() |> get(~p"/") |> html_response(200) |> LazyHTML.from_document()

    assert document |> LazyHTML.query("#sign-up-confirmation-hero") |> LazyHTML.text() =~
             "Check your email"

    assert document |> LazyHTML.query("form#sign-up-form-hero") |> Enum.count() == 0
  end

  test "signing up from the closing form brings the visitor back to its confirmation",
       %{conn: conn} do
    conn =
      post(conn, ~p"/sign-up", %{"form" => "closing", "user" => %{"email" => unique_user_email()}})

    assert redirected_to(conn) == ~p"/" <> "#access"

    document = conn |> recycle() |> get(~p"/") |> html_response(200) |> LazyHTML.from_document()

    assert document |> LazyHTML.query("#access #sign-up-confirmation-closing") |> LazyHTML.text() =~
             "Check your email"
  end

  test "signing up with an invalid email shows an error on that form and creates nothing",
       %{conn: conn} do
    user_count = Repo.aggregate(User, :count)
    account_count = Repo.aggregate(Account, :count)

    conn = post(conn, ~p"/sign-up", %{"form" => "closing", "user" => %{"email" => "not an email"}})

    document = conn |> html_response(422) |> LazyHTML.from_document()

    closing_email = LazyHTML.query(document, "#sign-up-closing-email")
    assert LazyHTML.attribute(closing_email, "aria-invalid") == ["true"]
    assert document |> LazyHTML.query("#sign-up-closing-email-error") |> Enum.count() == 1

    hero_email = LazyHTML.query(document, "#sign-up-hero-email")
    assert LazyHTML.attribute(hero_email, "aria-invalid") == []

    assert Repo.aggregate(User, :count) == user_count
    assert Repo.aggregate(Account, :count) == account_count
    assert_no_email_sent()
  end

  test "signing up with an existing email sends a sign-in link and the same confirmation, without a new account",
       %{conn: conn} do
    user = unconfirmed_user_fixture()
    account_count = Repo.aggregate(Account, :count)

    conn = post(conn, ~p"/sign-up", %{"form" => "hero", "user" => %{"email" => user.email}})

    assert redirected_to(conn) == ~p"/"
    assert Repo.aggregate(Account, :count) == account_count

    assert_email_sent(fn sent_email ->
      assert sent_email.to == [{"", user.email}]
      assert sent_email.text_body =~ "/users/log-in/"
    end)

    document = conn |> recycle() |> get(~p"/") |> html_response(200) |> LazyHTML.from_document()

    assert document |> LazyHTML.query("#sign-up-confirmation-hero") |> LazyHTML.text() =~
             "Check your email"
  end
end
