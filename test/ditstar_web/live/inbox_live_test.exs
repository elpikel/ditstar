defmodule DitstarWeb.InboxLiveTest do
  use DitstarWeb.ConnCase, async: true

  import Ditstar.AccountsFixtures
  import Phoenix.LiveViewTest

  test "a visitor who is not signed in is redirected to the sign-in page", %{conn: conn} do
    conn = get(conn, ~p"/app")

    assert redirected_to(conn) == ~p"/users/log-in"
  end

  test "a visitor who is not signed in is redirected to the sign-in page from a live navigation",
       %{conn: conn} do
    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, ~p"/app")
  end

  test "a signed-in user sees the inbox", %{conn: conn} do
    user = user_fixture()

    {:ok, lv, _html} = conn |> log_in_user(user) |> live(~p"/app")

    assert has_element?(lv, "#inbox")
  end

  test "the sidebar shows Inbox, Results and Setup with Inbox marked as the current page", %{conn: conn} do
    user = user_fixture()

    {:ok, lv, _html} = conn |> log_in_user(user) |> live(~p"/app")

    assert has_element?(lv, "#app-sidebar nav a[href='/app'][aria-current='page']", "Inbox")
    assert has_element?(lv, "#app-sidebar nav a[href='/app/results']:not([aria-current])", "Results")
    assert has_element?(lv, "#app-sidebar nav a[href='#{~p"/app/setup"}']:not([aria-current])", "Setup")
  end

  test "the sidebar shows the signed-in user's email with a log out link", %{conn: conn} do
    user = user_fixture()

    {:ok, lv, _html} = conn |> log_in_user(user) |> live(~p"/app")

    assert has_element?(lv, "#app-sidebar", user.email)
    assert has_element?(lv, "#app-sidebar a[href='/users/log-out'][data-method='delete']", "Log out")
  end

  test "the inbox shows the thread list with the first thread selected and its draft in the detail pane",
       %{conn: conn} do
    user = user_fixture()

    {:ok, lv, _html} = conn |> log_in_user(user) |> live(~p"/app")

    assert has_element?(
             lv,
             "#thread-list button[aria-pressed='true']",
             "Simple invoicing that handles EU VAT, without a full accounting suite?"
           )

    assert has_element?(lv, "#thread-detail #thread-draft", "Founder of [YOUR PRODUCT] here")
  end

  test "the inbox offers only posting from your own account, not the labelled paid choice", %{conn: conn} do
    user = user_fixture()

    {:ok, lv, _html} = conn |> log_in_user(user) |> live(~p"/app")

    assert has_element?(lv, "#thread-detail button[aria-pressed='true']", "You, from your account")
    refute has_element?(lv, "#thread-detail button", "Ditstar, labelled as paid")
  end
end
