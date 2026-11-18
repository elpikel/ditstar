defmodule DitstarWeb.ResultsLiveTest do
  use DitstarWeb.ConnCase, async: true

  import Ditstar.AccountsFixtures
  import Phoenix.LiveViewTest

  test "a visitor who is not signed in is redirected to the sign-in page", %{conn: conn} do
    conn = get(conn, ~p"/app/results")

    assert redirected_to(conn) == ~p"/users/log-in"
  end

  test "a visitor who is not signed in is redirected to the sign-in page from a live navigation",
       %{conn: conn} do
    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, ~p"/app/results")
  end

  test "the sidebar shows Inbox, Results and Setup with Results marked as the current page", %{conn: conn} do
    user = user_fixture()

    {:ok, lv, _html} = conn |> log_in_user(user) |> live(~p"/app/results")

    assert has_element?(lv, "#app-sidebar nav a[href='/app/results'][aria-current='page']", "Results")
    assert has_element?(lv, "#app-sidebar nav a[href='/app']:not([aria-current])", "Inbox")
    assert has_element?(lv, "#app-sidebar nav a[href='#{~p"/app/setup"}']:not([aria-current])", "Setup")
  end

  test "results shows the stat tiles and the table of posted replies", %{conn: conn} do
    user = user_fixture()

    {:ok, lv, _html} = conn |> log_in_user(user) |> live(~p"/app/results")

    assert has_element?(lv, "#results #results-stats", "Replies posted")
    assert has_element?(lv, "#results #results-stats", "Visits from replies")
    assert has_element?(lv, "#results #results-stats", "Signups")
    assert has_element?(lv, "#results-table td", "Simple invoicing that handles EU VAT")
  end

  test "the results table describes replies posted by Ditstar as labelled", %{conn: conn} do
    user = user_fixture()

    {:ok, lv, _html} = conn |> log_in_user(user) |> live(~p"/app/results")

    assert has_element?(lv, "#results-table td", "Ditstar, labelled")
  end
end
