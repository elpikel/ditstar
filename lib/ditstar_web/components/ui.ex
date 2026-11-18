defmodule DitstarWeb.UI do
  @moduledoc """
  Ditstar's design-system function components.

  Every colour, font and radius comes from the token utilities mapped in
  `assets/css/app.css` (see `docs/design/README.md`, "Components"). Components
  are presentational: callers pass data and event attributes in.

  Surfaces: `"light"` is the landing page, `"dark"` is slate or ink. The lime
  accent is only used on dark surfaces, or as a fill with on-accent text.
  """
  use Phoenix.Component

  import DitstarWeb.CoreComponents, only: [icon: 1, translate_error: 1]

  alias Phoenix.HTML.FormField

  @doc """
  Renders the star mark: a four-point star with two eyes, inline as SVG.

      <.star_mark />
      <.star_mark surface="dark" size={32} />
      <.star_mark label="Ditstar" />
  """
  attr :surface, :string, default: "light", values: ~w(light dark)
  attr :size, :integer, default: 24, doc: "width and height in pixels"
  attr :label, :string, default: nil, doc: "accessible name; the mark is decorative when nil"
  attr :class, :any, default: nil
  attr :rest, :global

  def star_mark(assigns) do
    ~H"""
    <svg
      viewBox="0 0 24 24"
      width={@size}
      height={@size}
      role={@label && "img"}
      aria-label={@label}
      aria-hidden={is_nil(@label) && "true"}
      class={["flex-none", @class]}
      {@rest}
    >
      <path
        d="M12 1.5l2.9 7.6 7.6 2.9-7.6 2.9-2.9 7.6-2.9-7.6L1.5 12l7.6-2.9z"
        class={star_fill(@surface)}
      />
      <circle cx="9.9" cy="11.8" r="1.15" class={star_eye_fill(@surface)} />
      <circle cx="14.1" cy="11.8" r="1.15" class={star_eye_fill(@surface)} />
    </svg>
    """
  end

  @doc """
  Renders a button, or a link styled as a button when given `href`,
  `navigate` or `patch`.

      <.button type="submit" size="landing">Create account</.button>
      <.button surface="dark" size="main">Save and start watching</.button>
      <.button variant="secondary" surface="dark" navigate={~p"/app"}>Edit draft</.button>
  """
  attr :variant, :string,
    default: "primary",
    values: ~w(primary secondary quiet),
    doc: "primary is filled, secondary is outlined, quiet is text only"

  attr :surface, :string, default: "light", values: ~w(light dark)

  attr :size, :string,
    default: "default",
    values: ~w(landing main default),
    doc: "landing is 56px, main (app main actions) is 52px, default is 44px"

  attr :type, :string, default: "button", doc: "the button type; ignored for links"
  attr :class, :any, default: nil

  attr :rest, :global, include: ~w(href navigate patch method download name value disabled form replace)

  slot :inner_block, required: true

  def button(%{rest: rest} = assigns) do
    assigns =
      assign(assigns, :classes, [
        "inline-flex cursor-pointer items-center justify-center gap-2 font-sans no-underline transition-colors",
        "disabled:cursor-not-allowed disabled:opacity-60 phx-submit-loading:opacity-75",
        button_size_class(assigns.size),
        button_variant_class(assigns.variant, assigns.surface),
        assigns.class
      ])

    if rest[:href] || rest[:navigate] || rest[:patch] do
      ~H"""
      <.link class={@classes} {@rest}>{render_slot(@inner_block)}</.link>
      """
    else
      ~H"""
      <button type={@type} class={@classes} {@rest}>{render_slot(@inner_block)}</button>
      """
    end
  end

  @doc """
  Renders a labelled text input. Accepts a `Phoenix.HTML.FormField` like the
  core `<.input>`, and shows the field's errors once it has been used.

      <.text_input field={@form[:email]} type="email" label="Work email" />
      <.text_input field={@form[:name]} label="Name" variant="slate" />

  The `action` slot renders beside the input on the same row, for the
  landing page's email-and-button forms.
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :label, :string, required: true

  attr :type, :string,
    default: "text",
    values: ~w(text email url password search tel number)

  attr :variant, :string,
    default: "light",
    values: ~w(light slate charcoal),
    doc: "light on the page, slate in the app, charcoal on the ink closing band"

  attr :field, FormField, doc: "a form field, for example @form[:email]"
  attr :errors, :list, default: []

  attr :rest, :global, include: ~w(autocomplete disabled form inputmode maxlength minlength pattern placeholder
                readonly required)

  slot :action, doc: "content placed beside the input, such as a submit button"

  def text_input(%{field: %FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error/1))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> text_input()
  end

  def text_input(assigns) do
    assigns = assign(assigns, :error_id, assigns.errors != [] && "#{assigns.id}-error")

    ~H"""
    <div class="flex flex-col gap-2">
      <label for={@id} class={["text-[13px] font-medium", input_label_class(@variant)]}>
        {@label}
      </label>
      <div class="flex flex-wrap gap-2.5">
        <input
          type={@type}
          id={@id}
          name={@name}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@error_id}
          class={[
            "min-w-0 flex-[1_1_220px] font-sans",
            input_variant_class(@variant),
            @errors != [] && input_error_class(@variant)
          ]}
          {@rest}
        />
        {render_slot(@action)}
      </div>
      <div :if={@errors != []} id={@error_id} class="flex flex-col gap-1">
        <p
          :for={message <- @errors}
          class={["flex items-center gap-1.5 text-[13px]", input_error_text_class(@variant)]}
        >
          <.icon name="hero-exclamation-circle" class="size-4" />
          {message}
        </p>
      </div>
    </div>
    """
  end

  @doc """
  Renders a small mono, uppercase label chip, as in the landing hero.

      <.label_chip>Reddit lead finder</.label_chip>
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def label_chip(assigns) do
    ~H"""
    <span
      class={[
        "rounded-chip bg-chip px-3 py-[7px] font-mono text-xs uppercase tracking-[0.1em] text-ink",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end

  @doc """
  Renders a chip for a keyword, subreddit or competitor on a dark surface,
  or the dashed "add" chip, which is a button.

      <.chip kind="keyword">invoicing</.chip>
      <.chip kind="competitor">
        [COMPETITOR]
        <:remove label="Remove [COMPETITOR]" phx-click="remove_competitor" phx-value-index="0" />
      </.chip>
      <.chip kind="add" phx-click="add_keyword">+ Add keyword</.chip>

  The `remove` slot renders a "×" button inside the chip. Any attributes given
  to the slot besides `label` go on that button.
  """
  attr :kind, :string,
    required: true,
    values: ~w(keyword subreddit competitor add),
    doc: "keyword is the matched accent fill, add is the dashed button"

  attr :size, :string,
    default: "default",
    values: ~w(default compact),
    doc: "default is the 36px Setup chip, compact is the small inline chip"

  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(name value disabled form)

  slot :inner_block, required: true

  slot :remove,
    validate_attrs: false,
    doc:
      "a remove button; `label` is its accessible name, for example \"Remove invoicing\", and other attributes go on the button"

  def chip(%{kind: "add"} = assigns) do
    ~H"""
    <button
      type="button"
      class={[
        "cursor-pointer border border-dashed border-on-slate-muted bg-transparent font-mono text-on-slate-2 transition-colors hover:text-on-slate",
        chip_size_class(@size),
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  def chip(assigns) do
    ~H"""
    <span
      class={[
        "inline-flex items-center gap-1.5 font-mono",
        chip_size_class(@size),
        chip_kind_class(@kind),
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
      <button
        :for={remove <- @remove}
        type="button"
        aria-label={remove.label}
        class={[
          "-mr-1 inline-flex size-6 cursor-pointer items-center justify-center rounded-chip opacity-70 transition-opacity hover:opacity-100",
          chip_remove_focus_class(@kind)
        ]}
        {assigns_to_attributes(remove, [:label])}
      >
        <.icon name="hero-x-mark" class="size-3.5" />
      </button>
    </span>
    """
  end

  @doc """
  Renders the intent tag of a thread.

      <.intent_tag kind="recommendation" />
  """
  attr :kind, :string, required: true, values: ~w(recommendation competitor related)
  attr :class, :any, default: nil
  attr :rest, :global

  def intent_tag(assigns) do
    ~H"""
    <span class={["text-[13px]", intent_class(@kind), @class]} {@rest}>{intent_label(@kind)}</span>
    """
  end

  @doc """
  Renders a thread row of the Inbox list: subreddit and age, title and intent
  tag. The selected row is pressed. Event attributes go on the button.

      <.thread_row
        subreddit="r/smallbusiness"
        age="2h ago"
        title="Simple invoicing that handles EU VAT?"
        intent="recommendation"
        selected
        phx-click="select_thread"
        phx-value-id="42"
      />
  """
  attr :subreddit, :string, required: true, doc: "for example \"r/smallbusiness\""
  attr :age, :string, required: true, doc: "for example \"2h ago\""
  attr :title, :string, required: true
  attr :intent, :string, required: true, values: ~w(recommendation competitor related)
  attr :selected, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(name value disabled form)

  def thread_row(assigns) do
    ~H"""
    <button
      type="button"
      aria-pressed={to_string(@selected)}
      class={[
        "flex w-full cursor-pointer flex-col items-start gap-2 border-0 border-b border-surface-slate-line px-5 py-[18px] text-left font-sans transition-colors",
        if(@selected,
          do: "bg-surface-slate-raised text-on-slate",
          else: "bg-transparent text-on-slate-2 hover:bg-surface-slate-raised"
        ),
        @class
      ]}
      {@rest}
    >
      <span class="font-mono text-[11px] text-on-slate-muted">{@subreddit} · {@age}</span>
      <span class={[
        "text-[15px] leading-[1.4]",
        if(@selected, do: "font-semibold", else: "font-medium")
      ]}>
        {@title}
      </span>
      <.intent_tag kind={@intent} />
    </button>
    """
  end

  @doc """
  Renders a sidebar nav link with an icon, a label and an optional count badge.

      <.nav_item icon="hero-inbox" navigate={~p"/app"} current count={3}>Inbox</.nav_item>
  """
  attr :icon, :string, required: true, doc: "a heroicon name, for example \"hero-inbox\""
  attr :current, :boolean, default: false, doc: "marks the current page"
  attr :count, :integer, default: nil, doc: "an optional count badge"
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(href navigate patch method replace)
  slot :inner_block, required: true

  def nav_item(assigns) do
    ~H"""
    <.link
      aria-current={@current && "page"}
      class={[
        "flex min-h-target-min items-center gap-3 rounded-control px-3 text-[15px] no-underline transition-colors",
        if(@current,
          do: "bg-surface-slate-selected font-semibold text-on-slate",
          else: "font-medium text-on-slate-2 hover:bg-surface-slate-raised hover:text-on-slate"
        ),
        @class
      ]}
      {@rest}
    >
      <.icon name={@icon} class="size-[18px]" />
      <span class="grow">{render_slot(@inner_block)}</span>
      <span
        :if={@count}
        class="rounded-pill bg-accent-lime px-2 py-0.5 font-mono text-[11px] font-medium text-on-accent"
      >
        {@count}
      </span>
    </.link>
    """
  end

  @doc """
  Renders pill filter tabs. The active tab is pressed. Attributes given to a
  tab besides `active` go on its button.

      <.filter_tabs label="Thread status">
        <:tab active phx-click="filter" phx-value-status="new">New · 3</:tab>
        <:tab phx-click="filter" phx-value-status="posted">Posted</:tab>
      </.filter_tabs>
  """
  attr :label, :string, required: true, doc: "accessible name of the group"
  attr :class, :any, default: nil
  attr :rest, :global

  slot :tab, required: true do
    attr :active, :boolean
  end

  def filter_tabs(assigns) do
    ~H"""
    <div role="group" aria-label={@label} class={["flex flex-wrap gap-1.5", @class]} {@rest}>
      <button
        :for={tab <- @tab}
        type="button"
        aria-pressed={to_string(tab[:active] == true)}
        class={[
          "min-h-9 cursor-pointer rounded-pill px-3.5 font-sans text-[13px] transition-colors",
          if(tab[:active],
            do: "bg-on-slate font-semibold text-ink",
            else: "bg-transparent font-medium text-on-slate-2 hover:bg-surface-slate-raised"
          )
        ]}
        {assigns_to_attributes(tab, [:active])}
      >
        {render_slot(tab)}
      </button>
    </div>
    """
  end

  @doc """
  Renders the draft box that holds a reply draft on a dark surface.

      <.draft_box>Founder of [YOUR PRODUCT] here...</.draft_box>
  """
  attr :size, :string,
    default: "default",
    values: ~w(default compact),
    doc: "default is the Inbox draft, compact is the landing preview"

  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def draft_box(assigns) do
    ~H"""
    <div
      class={[
        "border border-surface-slate-line-strong bg-surface-slate-raised leading-[1.6] text-on-slate",
        draft_size_class(@size),
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a choice between options, one selected. The selected option is
  pressed. Attributes given to an option besides `selected` and
  `description` go on its button.

      <.choice label="Who posts this one">
        <:option selected phx-click="poster" phx-value-poster="you">You, from your account</:option>
        <:option phx-click="poster" phx-value-poster="ditstar">Ditstar, labelled as paid</:option>
      </.choice>

  The `card` variant (Setup) shows each option's description under its title.
  """
  attr :label, :string, required: true, doc: "accessible name of the group"

  attr :variant, :string,
    default: "inline",
    values: ~w(inline card),
    doc: "inline is a row of 44px buttons, card is a grid of titled cards"

  attr :class, :any, default: nil
  attr :rest, :global

  slot :option,
    required: true,
    validate_attrs: false,
    doc:
      "an option; `selected` presses it, `description` is the card variant's text, and other attributes go on its button"

  def choice(assigns) do
    ~H"""
    <div role="group" aria-label={@label} class={[choice_group_class(@variant), @class]} {@rest}>
      <button
        :for={option <- @option}
        type="button"
        aria-pressed={to_string(option[:selected] == true)}
        class={[
          "cursor-pointer font-sans transition-colors",
          choice_option_class(@variant),
          choice_state_class(@variant, option[:selected] == true)
        ]}
        {assigns_to_attributes(option, [:selected, :description])}
      >
        <%= if @variant == "card" do %>
          <span class="text-base font-bold">{render_slot(option)}</span>
          <span :if={option[:description]} class="text-sm leading-normal text-on-slate-2">
            {option[:description]}
          </span>
        <% else %>
          {render_slot(option)}
        <% end %>
      </button>
    </div>
    """
  end

  @doc """
  Renders a callout: the star mark and one sentence in Ditstar's voice.

      <.callout>r/smallbusiness brought the most signups this month.</.callout>
      <.callout variant="greeting">Morning. I found 3 threads worth a reply today.</.callout>

  `raised` is the Results bar. `greeting` is the Inbox page heading and
  renders the sentence as an `h1`.
  """
  attr :variant, :string, default: "raised", values: ~w(raised greeting)
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def callout(%{variant: "greeting"} = assigns) do
    ~H"""
    <div class={["flex items-center gap-3.5", @class]} {@rest}>
      <.star_mark surface="dark" size={32} />
      <h1 class="text-xl font-bold tracking-[-0.02em] text-on-slate">
        {render_slot(@inner_block)}
      </h1>
    </div>
    """
  end

  def callout(assigns) do
    ~H"""
    <div
      class={[
        "flex items-center gap-3.5 rounded-card bg-surface-slate-raised px-[22px] py-[18px]",
        @class
      ]}
      {@rest}
    >
      <.star_mark surface="dark" size={30} />
      <p class="text-[17px] font-semibold leading-[1.4] text-on-slate">
        {render_slot(@inner_block)}
      </p>
    </div>
    """
  end

  @doc """
  Renders a stat tile: a label and one large number.

      <.stat_tile label="Signups" value={4} highlight />

  Only the Signups tile is `highlight`, which colours the number with the accent.
  """
  attr :label, :string, required: true
  attr :value, :any, required: true
  attr :highlight, :boolean, default: false
  attr :class, :any, default: nil
  attr :rest, :global

  def stat_tile(assigns) do
    ~H"""
    <div
      class={[
        "flex flex-col gap-2 rounded-card border border-surface-slate-line px-6 py-[22px]",
        @class
      ]}
      {@rest}
    >
      <span class="text-sm text-on-slate-2">{@label}</span>
      <span class={[
        "text-[44px] font-extrabold leading-none tracking-[-0.03em]",
        if(@highlight, do: "text-accent-lime", else: "text-on-slate")
      ]}>
        {@value}
      </span>
    </div>
    """
  end

  @doc """
  Renders a data table on a dark surface that scrolls horizontally inside its
  own box on narrow screens.

      <.data_table id="replies" rows={@replies}>
        <:col :let={reply} label="Reply" strong>{reply.title}</:col>
        <:col :let={reply} label="Subreddit" mono muted>{reply.subreddit}</:col>
        <:col :let={reply} label="Visits" numeric>{reply.visits}</:col>
      </.data_table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "a function that returns each row's DOM id"
  attr :class, :any, default: nil

  slot :col, required: true do
    attr :label, :string, required: true
    attr :numeric, :boolean, doc: "right-aligned mono numbers"
    attr :mono, :boolean, doc: "mono 13px text, such as a subreddit"
    attr :muted, :boolean, doc: "secondary text colour"
    attr :strong, :boolean, doc: "semibold text, for the leading column"
  end

  def data_table(assigns) do
    ~H"""
    <div class={["overflow-x-auto rounded-card border border-surface-slate-line", @class]}>
      <table id={@id} class="w-full min-w-[720px] border-collapse text-[15px] text-on-slate">
        <thead>
          <tr class="text-left font-mono text-[11px] uppercase tracking-[0.08em] text-on-slate-muted">
            <th
              :for={col <- @col}
              scope="col"
              class={[
                "border-b border-surface-slate-line px-4 py-3.5 font-medium first:pl-5 last:pr-5",
                col[:numeric] && "text-right"
              ]}
            >
              {col.label}
            </th>
          </tr>
        </thead>
        <tbody class="[&>tr:last-child>td]:border-b-0">
          <tr :for={row <- @rows} id={@row_id && @row_id.(row)}>
            <td
              :for={col <- @col}
              class={[
                "border-b border-surface-slate-line px-4 py-[18px] first:pl-5 last:pr-5",
                col[:numeric] && "text-right font-mono",
                col[:mono] && "font-mono text-[13px]",
                col[:muted] && "text-on-slate-2",
                col[:strong] && "font-semibold"
              ]}
            >
              {render_slot(col, row)}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Renders a landing page feature card: a mono step label, a question heading,
  one paragraph, and a small slate preview pinned to the bottom.

      <.feature_card step="01 · Find" title="Where are people asking?">
        Ditstar watches the subreddits...
        <:preview>...</:preview>
      </.feature_card>
  """
  attr :step, :string, required: true
  attr :title, :string, required: true
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true
  slot :preview, doc: "the slate preview pinned to the bottom of the card"

  def feature_card(assigns) do
    ~H"""
    <div
      class={["flex flex-col gap-3.5 rounded-feature border border-line bg-white p-7", @class]}
      {@rest}
    >
      <span class="font-mono text-xs text-body-muted">{@step}</span>
      <h3 class="text-[26px] font-bold leading-[1.15] tracking-[-0.02em] text-ink">{@title}</h3>
      <p class="text-base leading-[1.6] text-body">{render_slot(@inner_block)}</p>
      <div
        :for={preview <- @preview}
        class="surface-dark mt-auto flex flex-col gap-3.5 rounded-xl bg-surface-slate p-[18px] text-on-slate"
      >
        {render_slot(preview)}
      </div>
    </div>
    """
  end

  @doc """
  Renders the founder note: the photo placeholder, a large first-person
  paragraph and a handwritten signature.

      <.founder_note label="From the founder" signature="Arkadiusz" role="Founder, Ditstar">
        I built Ditstar for my own products first...
      </.founder_note>
  """
  attr :label, :string, required: true
  attr :signature, :string, required: true
  attr :role, :string, required: true
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def founder_note(assigns) do
    ~H"""
    <div class={["flex flex-wrap items-center gap-14", @class]} {@rest}>
      <div class="flex aspect-square w-[280px] max-w-full flex-none items-center justify-center rounded-3xl border-[1.5px] border-dashed border-line-dashed font-mono text-[13px] text-body-muted">
        [YOUR PHOTO]
      </div>
      <div class="flex min-w-0 flex-[1_1_480px] flex-col gap-6">
        <span class="font-mono text-xs uppercase tracking-[0.1em] text-body-muted">{@label}</span>
        <p class="text-[clamp(21px,2.1vw,30px)] font-semibold leading-[1.35] tracking-[-0.02em] text-pretty text-ink">
          {render_slot(@inner_block)}
        </p>
        <div class="flex flex-col gap-1">
          <span class="font-hand text-[44px] font-semibold leading-none text-ink">{@signature}</span>
          <span class="text-sm text-body-muted">{@role}</span>
        </div>
      </div>
    </div>
    """
  end

  defp star_fill("light"), do: "fill-ink"
  defp star_fill("dark"), do: "fill-accent-lime"

  defp star_eye_fill("light"), do: "fill-page"
  defp star_eye_fill("dark"), do: "fill-on-accent"

  defp button_size_class("landing"), do: "h-14 rounded-control px-6 text-base"
  defp button_size_class("main"), do: "min-h-13 rounded-control-app px-[22px] text-base"
  defp button_size_class("default"), do: "min-h-target-min rounded-control px-4 text-sm"

  defp button_variant_class("primary", "light"), do: "border-0 bg-ink font-semibold text-white hover:opacity-90"

  defp button_variant_class("primary", "dark"),
    do: "border-0 bg-accent-lime font-semibold text-on-accent hover:brightness-105"

  defp button_variant_class("secondary", "light"),
    do: "border border-line-strong bg-transparent font-medium text-ink hover:bg-chip"

  defp button_variant_class("secondary", "dark"),
    do: "border border-surface-slate-line-strong bg-transparent font-medium text-on-slate hover:bg-surface-slate-raised"

  defp button_variant_class("quiet", "light"), do: "border-0 bg-transparent font-medium text-body hover:text-ink"

  defp button_variant_class("quiet", "dark"),
    do: "border-0 bg-transparent font-medium text-on-slate-2 hover:text-on-slate"

  defp input_label_class("light"), do: "text-body-muted"
  defp input_label_class("slate"), do: "text-on-slate-2"
  defp input_label_class("charcoal"), do: "text-on-slate-muted"

  defp input_variant_class("light"),
    do:
      "h-14 rounded-control border-[1.5px] border-line-strong bg-white px-[18px] text-base text-ink placeholder:text-body-muted"

  defp input_variant_class("slate"),
    do:
      "h-12 rounded-control border border-surface-slate-line-strong bg-surface-slate-raised px-3.5 text-[15px] text-on-slate placeholder:text-on-slate-muted"

  defp input_variant_class("charcoal"),
    do:
      "h-14 rounded-control border border-surface-slate-line-strong bg-charcoal-raised px-[18px] text-base text-on-slate placeholder:text-on-slate-muted"

  defp input_error_class("light"), do: "border-ink"
  defp input_error_class(_dark), do: "border-warn"

  defp input_error_text_class("light"), do: "text-ink"
  defp input_error_text_class(_dark), do: "text-warn"

  defp chip_size_class("default"), do: "min-h-9 rounded-lg px-3 text-[13px]"
  defp chip_size_class("compact"), do: "rounded-chip px-[9px] py-1 text-xs"

  defp chip_kind_class("keyword"), do: "bg-accent-lime text-on-accent"
  defp chip_kind_class("subreddit"), do: "border border-surface-slate-line-strong text-on-slate"
  defp chip_kind_class("competitor"), do: "border border-surface-slate-line-strong text-warn"

  defp chip_remove_focus_class("keyword"), do: "focus-visible:outline-on-accent"
  defp chip_remove_focus_class(_outlined_kind), do: nil

  defp intent_class("recommendation"), do: "text-accent-lime"
  defp intent_class("competitor"), do: "text-warn"
  defp intent_class("related"), do: "text-on-slate-2"

  defp intent_label("recommendation"), do: "Asking for a recommendation"
  defp intent_label("competitor"), do: "Unhappy with a competitor"
  defp intent_label("related"), do: "Related question"

  defp draft_size_class("default"), do: "rounded-card px-[22px] py-5 text-[17px]"
  defp draft_size_class("compact"), do: "rounded-xl px-[18px] py-4 text-base"

  defp choice_group_class("inline"), do: "flex flex-wrap gap-2"

  defp choice_group_class("card"), do: "grid grid-cols-[repeat(auto-fit,minmax(min(280px,100%),1fr))] gap-3"

  defp choice_option_class("inline"), do: "min-h-target-min rounded-control px-4 text-sm"

  defp choice_option_class("card"), do: "flex flex-col items-start gap-2 rounded-control-app px-5 py-[18px] text-left"

  defp choice_state_class("inline", true),
    do: "border-[1.5px] border-on-slate bg-surface-slate-selected font-semibold text-on-slate"

  defp choice_state_class("card", true), do: "border-[1.5px] border-on-slate bg-surface-slate-selected text-on-slate"

  defp choice_state_class("inline", false),
    do: "border border-surface-slate-line-strong bg-transparent font-medium text-on-slate-2 hover:bg-surface-slate-raised"

  defp choice_state_class("card", false),
    do: "border border-surface-slate-line-strong bg-transparent text-on-slate hover:bg-surface-slate-raised"
end
