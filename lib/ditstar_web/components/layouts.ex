defmodule DitstarWeb.Layouts do
  @moduledoc """
  The embedded root template plus the app, landing and auth layouts, and the
  flash group they render.
  """
  use DitstarWeb, :html

  alias Ditstar.Products.Product

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders the app shell: the slate sidebar with the logo, the product
  switcher, the main navigation and the signed-in user's links, beside the
  page content. Below about 780px the sidebar stacks above the content.

      <Layouts.app flash={@flash} current_scope={@current_scope} current_page={:inbox}>
        <div id="inbox">...</div>
      </Layouts.app>

  `current_product` names the product switcher and `products` fills its menu;
  without them the switcher shows the `[YOUR PRODUCT]` placeholder and only
  offers "Add product". `current_page` marks its nav item with
  `aria-current="page"`. `inbox_count`
  shows a count badge on the Inbox item. `example_data` labels the page's
  content as example data.
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://phoenix.hexdocs.pm/scopes.html)"

  attr :current_product, :map, default: nil, doc: "the Current Product, named in the switcher"
  attr :products, :list, default: [], doc: "the Account's Products, listed in the switcher"

  attr :current_page, :atom,
    default: nil,
    values: [nil, :inbox, :results, :setup],
    doc: "the nav item of the page being shown"

  attr :inbox_count, :integer, default: nil, doc: "the count badge on the Inbox nav item"
  attr :example_data, :boolean, default: false, doc: "labels the content as example data"

  slot :inner_block, required: true

  def app(assigns) do
    assigns = assign(assigns, :nav_items, app_nav_items(assigns.inbox_count))

    ~H"""
    <div
      data-surface="dark"
      class="flex min-h-screen flex-wrap items-stretch bg-surface-slate font-sans text-on-slate"
    >
      <aside
        id="app-sidebar"
        class="flex min-w-0 grow basis-sidebar flex-col gap-6 border-r border-surface-slate-line bg-surface-slate-sidebar px-4 pt-3 pb-[22px]"
      >
        <.link
          navigate={~p"/app"}
          class="flex min-h-target-min items-center gap-[9px] px-2 text-xl font-extrabold tracking-[-0.03em] text-on-slate no-underline"
        >
          <.star_mark surface="dark" />
          <span>ditstar</span>
        </.link>

        <.product_switcher current_product={@current_product} products={@products} />

        <nav aria-label="Main" class="flex flex-col gap-1">
          <.nav_item
            :for={item <- @nav_items}
            icon={item.icon}
            navigate={item.path}
            current={item.page == @current_page}
            count={item.count}
          >
            {item.label}
          </.nav_item>
        </nav>

        <div class="mt-auto flex flex-col gap-3">
          <span :if={@example_data} class="px-3 font-mono text-[11px] text-on-slate-muted">
            Example data
          </span>
          <.signed_in_user :if={@current_scope} user={@current_scope.user} />
        </div>
      </aside>

      <main class="flex min-w-0 grow-999 basis-[560px] flex-col">
        {render_slot(@inner_block)}
      </main>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Renders the landing page layout: the page background, the header with the
  logo, the section links and the sign-up call to action, and the footer.

  The header floats: it sticks to the top of the viewport while scrolling.
  The two text links hide at 640px and below.

      <Layouts.landing flash={@flash}>
        <section id="how">...</section>
      </Layouts.landing>
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  slot :inner_block, required: true

  def landing(assigns) do
    ~H"""
    <div id="top" class="flex min-h-screen flex-col bg-page font-sans text-ink">
      <header
        id="landing-header"
        class="sticky top-3 z-40 mx-auto mt-3 w-full max-w-container px-[calc(var(--gutter)-16px)]"
      >
        <div class="flex flex-wrap items-center justify-between gap-6 rounded-card border border-line bg-page/80 px-4 py-2 shadow-[0_10px_30px_-12px_color-mix(in_oklab,var(--ink)_22%,transparent)] backdrop-blur-md">
          <a
            href="#top"
            class="flex min-h-target-min items-center gap-[9px] text-[21px] font-extrabold tracking-[-0.03em] text-ink no-underline"
          >
            <.star_mark />
            <span>ditstar</span>
          </a>
          <nav class="flex flex-wrap items-center gap-7 text-sm font-medium">
            <a
              :for={link <- landing_section_links()}
              href={link.href}
              class="inline-flex min-h-target-min items-center text-body-muted no-underline transition-colors hover:text-ink [@media(max-width:640px)]:hidden"
            >
              {link.label}
            </a>
            <.button href="#access">Create account</.button>
          </nav>
        </div>
      </header>

      <main class="flex grow flex-col">
        {render_slot(@inner_block)}
      </main>

      <footer
        data-surface="dark"
        class="border-t border-charcoal-line bg-ink text-on-slate-muted"
      >
        <div class="mx-auto flex max-w-container flex-wrap justify-between gap-3 px-gutter py-6 font-mono text-xs">
          <span>ditstar.com</span>
          <span>© 2026 Ditstar</span>
        </div>
      </footer>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Renders the sign-in layout: a centred card on the page background, under
  the star mark and the wordmark.

      <Layouts.auth flash={@flash}>
        <h1>Sign in</h1>
      </Layouts.auth>
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  slot :inner_block, required: true

  def auth(assigns) do
    ~H"""
    <div class="flex min-h-screen flex-col items-center justify-center gap-8 bg-page px-gutter py-section-y font-sans text-ink">
      <a
        href={~p"/"}
        class="flex min-h-target-min items-center gap-[9px] text-[21px] font-extrabold tracking-[-0.03em] text-ink no-underline"
      >
        <.star_mark />
        <span>ditstar</span>
      </a>
      <main class="flex w-full max-w-[420px] flex-col gap-6 rounded-card border border-line bg-white p-8">
        {render_slot(@inner_block)}
      </main>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={
          show(".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: ".phx-client-error #client-error")
        }
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={
          show(".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: ".phx-server-error #server-error")
        }
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  attr :current_product, :map, required: true
  attr :products, :list, required: true

  defp product_switcher(assigns) do
    ~H"""
    <details id="product-switcher" class="group flex flex-col gap-1">
      <summary class="flex min-h-target-min cursor-pointer list-none items-center justify-between gap-2 rounded-control border border-surface-slate-line px-3 font-mono text-xs text-on-slate transition-colors hover:bg-surface-slate-raised [&::-webkit-details-marker]:hidden">
        <span class="truncate">
          <span class="sr-only">Switch product, current:</span>
          {product_name(@current_product)}
        </span>
        <.icon
          name="hero-chevron-down"
          class="size-3.5 shrink-0 text-on-slate-muted transition-transform group-open:rotate-180"
        />
      </summary>

      <div class="flex flex-col gap-1 rounded-control border border-surface-slate-line bg-surface-slate p-1">
        <.form
          :for={product <- @products}
          for={%{}}
          id={"product-switcher-#{product.id}"}
          action={~p"/app/current-product"}
          method="put"
        >
          <input type="hidden" name="product_id" value={product.id} />
          <button
            type="submit"
            aria-current={current_product?(product, @current_product) && "true"}
            class={[
              "flex min-h-target-min w-full cursor-pointer items-center rounded-control px-3 text-left text-[13px] transition-colors",
              if(current_product?(product, @current_product),
                do: "bg-surface-slate-selected font-semibold text-on-slate",
                else: "font-medium text-on-slate-2 hover:bg-surface-slate-raised hover:text-on-slate"
              )
            ]}
          >
            <span class="truncate">{product.name}</span>
          </button>
        </.form>
        <.link
          href={~p"/app/setup/new"}
          class="flex min-h-target-min items-center gap-2 rounded-control px-3 text-[13px] font-medium text-on-slate-2 no-underline transition-colors hover:bg-surface-slate-raised hover:text-on-slate"
        >
          <.icon name="hero-plus" class="size-3.5" />
          <span>Add product</span>
        </.link>
      </div>
    </details>
    """
  end

  defp product_name(%Product{name: name}), do: name
  defp product_name(nil), do: "[YOUR PRODUCT]"

  defp current_product?(%Product{id: id}, %Product{id: id}), do: true
  defp current_product?(%Product{}, _current_product), do: false

  attr :user, :map, required: true

  defp signed_in_user(assigns) do
    ~H"""
    <div class="flex flex-col gap-1 border-t border-surface-slate-line pt-3">
      <span class="truncate px-3 font-mono text-[11px] text-on-slate-muted">{@user.email}</span>
      <div class="flex flex-wrap">
        <.link href={~p"/users/settings"} class={sidebar_account_link_class()}>Settings</.link>
        <.link href={~p"/users/log-out"} method="delete" class={sidebar_account_link_class()}>
          Log out
        </.link>
      </div>
    </div>
    """
  end

  defp sidebar_account_link_class,
    do:
      "inline-flex min-h-target-min items-center rounded-control px-3 text-[13px] font-medium text-on-slate-2 no-underline transition-colors hover:text-on-slate"

  defp app_nav_items(inbox_count) do
    [
      %{page: :inbox, label: "Inbox", icon: "hero-inbox", path: ~p"/app", count: inbox_count},
      %{page: :results, label: "Results", icon: "hero-chart-bar", path: ~p"/app/results", count: nil},
      %{page: :setup, label: "Setup", icon: "hero-adjustments-horizontal", path: ~p"/app/setup", count: nil}
    ]
  end

  defp landing_section_links do
    [
      %{href: "#how", label: "How it works"},
      %{href: "#replying", label: "Replying"}
    ]
  end
end
