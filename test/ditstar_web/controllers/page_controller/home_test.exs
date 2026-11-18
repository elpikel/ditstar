defmodule DitstarWeb.Controllers.PageController.HomeTest do
  use DitstarWeb.ConnCase, async: true

  test "a visitor opening the landing page gets it", %{conn: conn} do
    conn = get(conn, ~p"/")

    assert html_response(conn, 200)
  end

  test "the hero headline says your next customers are on Reddit and to answer them first",
       %{conn: conn} do
    document = conn |> get(~p"/") |> html_response(200) |> LazyHTML.from_document()

    headline =
      document
      |> LazyHTML.query("h1")
      |> LazyHTML.text()
      |> String.split()
      |> Enum.join(" ")

    assert headline == "Your next customers are on Reddit. Answer them first."

    page_text = document |> LazyHTML.query("body") |> LazyHTML.text()

    refute page_text =~ "Someone on Reddit is asking for your product"
    refute page_text =~ "right now."
  end

  test "the hero sign-up form has a labelled email input and a Create account button",
       %{conn: conn} do
    document = conn |> get(~p"/") |> html_response(200) |> LazyHTML.from_document()

    form = LazyHTML.query(document, "form#sign-up-form-hero")
    email_input = LazyHTML.query(form, "input[type=email][name='user[email]']")
    [email_input_id] = LazyHTML.attribute(email_input, "id")

    assert form |> LazyHTML.query("label[for='#{email_input_id}']") |> LazyHTML.text() =~
             "Work email"

    assert form |> LazyHTML.query("button[type=submit]") |> LazyHTML.text() |> String.trim() ==
             "Create account"
  end

  test "the closing sign-up form has a labelled email input and a Create account button",
       %{conn: conn} do
    document = conn |> get(~p"/") |> html_response(200) |> LazyHTML.from_document()

    form = LazyHTML.query(document, "form#sign-up-form-closing")
    email_input = LazyHTML.query(form, "input[type=email][name='user[email]']")
    [email_input_id] = LazyHTML.attribute(email_input, "id")

    assert form |> LazyHTML.query("label[for='#{email_input_id}']") |> LazyHTML.text() =~
             "Work email"

    assert form |> LazyHTML.query("button[type=submit]") |> LazyHTML.text() |> String.trim() ==
             "Create account"
  end

  test "the header links reach the how, replying and access sections", %{conn: conn} do
    document = conn |> get(~p"/") |> html_response(200) |> LazyHTML.from_document()

    header_targets = document |> LazyHTML.query("header a") |> LazyHTML.attribute("href")

    for section_id <- ~w(how replying access) do
      assert "##{section_id}" in header_targets
      assert document |> LazyHTML.query("section##{section_id}") |> Enum.count() == 1
    end
  end

  test "the landing page header has the landing-header id", %{conn: conn} do
    document = conn |> get(~p"/") |> html_response(200) |> LazyHTML.from_document()

    assert document |> LazyHTML.query("header#landing-header") |> Enum.count() == 1
  end

  test "the hero subhead says replies can go out on autopilot", %{conn: conn} do
    document = conn |> get(~p"/") |> html_response(200) |> LazyHTML.from_document()

    assert document |> LazyHTML.query("p#hero-subhead") |> LazyHTML.text() =~ "autopilot"
  end

  test "how it works shows the set up, pace, reply and track feature cards", %{conn: conn} do
    document = conn |> get(~p"/") |> html_response(200) |> LazyHTML.from_document()

    for feature_id <- ~w(feature-setup feature-pace feature-reply feature-track) do
      assert document |> LazyHTML.query("section#how ##{feature_id}") |> Enum.count() == 1
    end

    assert document |> LazyHTML.query("section#how [id^=feature-]") |> Enum.count() == 4
  end

  test "the landing page never mentions early access or a waitlist", %{conn: conn} do
    page_text =
      conn
      |> get(~p"/")
      |> html_response(200)
      |> LazyHTML.from_document()
      |> LazyHTML.query("body")
      |> LazyHTML.text()
      |> String.downcase()

    refute page_text =~ "early access"
    refute page_text =~ "waitlist"
  end

  test "the landing page head links the svg favicon, the ico fallback and the apple touch icon",
       %{conn: conn} do
    document = conn |> get(~p"/") |> html_response(200) |> LazyHTML.from_document()

    assert document
           |> LazyHTML.query("head link[rel=icon][type='image/svg+xml'][href='/favicon.svg']")
           |> Enum.count() == 1

    assert document
           |> LazyHTML.query("head link[rel=icon][sizes='32x32'][href='/favicon.ico']")
           |> Enum.count() == 1

    assert document
           |> LazyHTML.query("head link[rel=apple-touch-icon][href='/apple-touch-icon.png']")
           |> Enum.count() == 1
  end

  test "the svg favicon is served as an svg image", %{conn: conn} do
    conn = get(conn, "/favicon.svg")

    assert response(conn, 200)
    assert [content_type] = get_resp_header(conn, "content-type")
    assert content_type =~ "image/svg+xml"
  end
end
