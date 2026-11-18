defmodule DitstarWeb.UITest do
  use ExUnit.Case, async: true

  import DitstarWeb.UI
  import Phoenix.Component
  import Phoenix.LiveViewTest

  test "a button without a destination renders a button element" do
    assigns = %{}

    document =
      render_document(~H"""
      <.button id="save">Save and start watching</.button>
      """)

    assert [_button] = document |> LazyHTML.query("button#save") |> Enum.to_list()
  end

  test "a button given an href renders a link to it" do
    assigns = %{}

    document =
      render_document(~H"""
      <.button id="access" href="#access">Create account</.button>
      """)

    assert ["#access"] = document |> LazyHTML.query("a#access") |> LazyHTML.attribute("href")
  end

  test "a button given navigate renders a link to that path" do
    assigns = %{}

    document =
      render_document(~H"""
      <.button id="inbox" navigate="/app" surface="dark" size="main">Inbox</.button>
      """)

    assert ["/app"] = document |> LazyHTML.query("a#inbox") |> LazyHTML.attribute("href")
  end

  test "the star mark is an inline svg coloured by tokens, with no hex values" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.star_mark id="logo" />
      <.star_mark id="callout-mark" surface="dark" size={32} />
      """)

    document = LazyHTML.from_fragment(html)

    assert [_light, _dark] = document |> LazyHTML.query("svg") |> Enum.to_list()
    refute html =~ ~r/#[0-9a-fA-F]{3,6}\b/
  end

  test "the current nav item is marked as the current page" do
    assigns = %{}

    document =
      render_document(~H"""
      <.nav_item id="nav-inbox" icon="hero-inbox" navigate="/app" current count={3}>Inbox</.nav_item>
      <.nav_item id="nav-results" icon="hero-chart-bar" navigate="/app/results">Results</.nav_item>
      """)

    assert ["page"] =
             document |> LazyHTML.query("a#nav-inbox") |> LazyHTML.attribute("aria-current")

    assert [] = document |> LazyHTML.query("a#nav-results[aria-current]") |> Enum.to_list()
  end

  test "the selected choice is pressed and the other is not" do
    assigns = %{}

    document =
      render_document(~H"""
      <.choice label="Who posts this one">
        <:option id="choice-you" selected>You, from your account</:option>
        <:option id="choice-ditstar">Ditstar, labelled as paid</:option>
      </.choice>
      """)

    assert ["true"] =
             document |> LazyHTML.query("button#choice-you") |> LazyHTML.attribute("aria-pressed")

    assert ["false"] =
             document
             |> LazyHTML.query("button#choice-ditstar")
             |> LazyHTML.attribute("aria-pressed")
  end

  test "the active filter tab is pressed" do
    assigns = %{}

    document =
      render_document(~H"""
      <.filter_tabs label="Thread status">
        <:tab id="tab-new" active>New · 3</:tab>
        <:tab id="tab-posted">Posted</:tab>
      </.filter_tabs>
      """)

    assert ["true"] =
             document |> LazyHTML.query("button#tab-new") |> LazyHTML.attribute("aria-pressed")

    assert ["false"] =
             document |> LazyHTML.query("button#tab-posted") |> LazyHTML.attribute("aria-pressed")
  end

  test "a removable chip has a remove button named for the chip" do
    assigns = %{}

    document =
      render_document(~H"""
      <.chip id="keyword-invoicing" kind="keyword">
        invoicing <:remove label="Remove invoicing" name="product[keywords_drop][]" value="0" />
      </.chip>
      """)

    assert ["Remove invoicing"] =
             document
             |> LazyHTML.query("#keyword-invoicing button")
             |> LazyHTML.attribute("aria-label")
  end

  test "the add chip is a button" do
    assigns = %{}

    document =
      render_document(~H"""
      <.chip id="add-keyword" kind="add">+ Add keyword</.chip>
      """)

    assert ["button"] =
             document |> LazyHTML.query("button#add-keyword") |> LazyHTML.attribute("type")
  end

  test "a text input for a form field has a label tied to the input" do
    form = to_form(%{"email" => ""}, as: :user)
    assigns = %{form: form}

    document =
      render_document(~H"""
      <.text_input field={@form[:email]} type="email" label="Work email" />
      """)

    assert ["user_email"] = document |> LazyHTML.query("label") |> LazyHTML.attribute("for")

    assert ["user[email]"] =
             document |> LazyHTML.query("input#user_email") |> LazyHTML.attribute("name")
  end

  test "a text input with a hidden label keeps a screen-reader-only label tied to the input" do
    form = to_form(%{"email" => ""}, as: :user)
    assigns = %{form: form}

    document =
      render_document(~H"""
      <.text_input field={@form[:email]} type="email" label="Work email" hide_label />
      """)

    label = LazyHTML.query(document, "label.sr-only[for=user_email]")

    assert label |> LazyHTML.text() |> String.trim() == "Work email"
    assert document |> LazyHTML.query("input#user_email") |> Enum.count() == 1
  end

  test "a text input shows its label visibly by default" do
    form = to_form(%{"email" => ""}, as: :user)
    assigns = %{form: form}

    document =
      render_document(~H"""
      <.text_input field={@form[:email]} type="email" label="Work email" />
      """)

    assert document |> LazyHTML.query("label[for=user_email]") |> Enum.count() == 1
    assert document |> LazyHTML.query("label.sr-only") |> Enum.count() == 0
  end

  test "a text input shows the errors of a used form field" do
    form = to_form(%{"email" => "nope"}, as: :user, errors: [email: {"must have the @ sign", []}])
    assigns = %{form: form}

    document =
      render_document(~H"""
      <.text_input field={@form[:email]} type="email" label="Work email" variant="charcoal" />
      """)

    assert ["true"] =
             document |> LazyHTML.query("input#user_email") |> LazyHTML.attribute("aria-invalid")

    assert LazyHTML.text(document) =~ "must have the @ sign"
  end

  test "the data table right-aligns numeric columns" do
    assigns = %{rows: [%{reply: "Chasing late invoices", visits: 9}]}

    document =
      render_document(~H"""
      <.data_table id="replies" rows={@rows}>
        <:col :let={row} label="Reply">{row.reply}</:col>
        <:col :let={row} label="Visits" numeric>{row.visits}</:col>
      </.data_table>
      """)

    assert ["Reply", "Visits"] =
             document
             |> LazyHTML.query("#replies th")
             |> Enum.map(&(&1 |> LazyHTML.text() |> String.trim()))

    assert [_numeric_cell] =
             document |> LazyHTML.query("#replies td.text-right") |> Enum.to_list()
  end

  test "the stat tile shows its label and number" do
    assigns = %{}

    document =
      render_document(~H"""
      <.stat_tile id="signups" label="Signups" value={4} highlight />
      """)

    assert LazyHTML.text(document) =~ "Signups"
    assert LazyHTML.text(document) =~ "4"
  end

  test "the intent tag names the intent of its kind" do
    assigns = %{}

    document =
      render_document(~H"""
      <.intent_tag kind="competitor" />
      """)

    assert LazyHTML.text(document) =~ "Unhappy with a competitor"
  end

  test "the selected thread row is pressed and the others are not" do
    assigns = %{}

    document =
      render_document(~H"""
      <.thread_row
        id="thread-invoicing"
        subreddit="r/smallbusiness"
        age="2h ago"
        title="Simple invoicing that handles EU VAT?"
        intent="recommendation"
        selected
      />
      <.thread_row
        id="thread-late-invoices"
        subreddit="r/Entrepreneur"
        age="9h ago"
        title="How do you chase late invoices without sounding rude?"
        intent="related"
      />
      """)

    assert ["true"] =
             document
             |> LazyHTML.query("button#thread-invoicing")
             |> LazyHTML.attribute("aria-pressed")

    assert ["false"] =
             document
             |> LazyHTML.query("button#thread-late-invoices")
             |> LazyHTML.attribute("aria-pressed")
  end

  defp render_document(rendered) do
    rendered
    |> rendered_to_string()
    |> LazyHTML.from_fragment()
  end
end
