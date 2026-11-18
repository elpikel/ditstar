defmodule DitstarWeb.InboxLive do
  @moduledoc false
  use DitstarWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      current_product={@current_product}
      products={@products}
      current_page={:inbox}
      inbox_count={3}
      example_data
    >
      <div id="inbox" class="flex grow flex-col">
        <.callout
          variant="greeting"
          id="inbox-title"
          class="border-b border-surface-slate-line px-8 py-[22px]"
        >
          Morning. I found 3 threads worth a reply today.
        </.callout>

        <div class="flex grow flex-wrap items-stretch">
          <section
            id="thread-list"
            aria-label="Threads"
            class="flex min-w-0 flex-[1_1_320px] flex-col border-r border-surface-slate-line"
          >
            <.filter_tabs label="Thread status" class="border-b border-surface-slate-line px-4 py-3.5">
              <:tab active>New · 3</:tab>
              <:tab>Posted</:tab>
              <:tab>Skipped</:tab>
            </.filter_tabs>
            <.thread_row
              :for={thread <- @threads}
              subreddit={thread.subreddit}
              age={thread.age}
              title={thread.title}
              intent={thread.intent}
              selected={thread.selected}
            />
          </section>

          <.thread_detail />
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :threads, example_threads())}
  end

  defp thread_detail(assigns) do
    ~H"""
    <section
      id="thread-detail"
      aria-label="Thread and draft"
      class="flex min-w-0 flex-[2_1_480px] flex-col gap-6 px-9 pt-7 pb-9"
    >
      <div class="flex max-w-[700px] flex-col gap-3">
        <div class="flex flex-wrap items-center justify-between gap-3">
          <span class="font-mono text-xs text-on-slate-muted">
            r/smallbusiness · asking for a recommendation
          </span>
          <a
            href="#"
            class="flex min-h-target-min items-center gap-1.5 text-[13px] font-medium text-on-slate-2 no-underline transition-colors hover:text-on-slate"
          >
            <span>Open on Reddit</span>
            <.icon name="hero-arrow-up-right" class="size-3.5" />
          </a>
        </div>
        <h2 class="text-[26px] font-bold leading-[1.25] tracking-[-0.02em]">
          Simple invoicing that handles EU VAT, without a full accounting suite?
        </h2>
        <p class="text-base leading-[1.6] text-on-slate-2">
          I sell to a handful of clients across the EU and only need invoices with the right VAT on them. Everything I find wants to be my whole accounting system. What do you all use?
        </p>
        <div class="flex flex-wrap items-center gap-2 font-mono text-xs">
          <span class="text-on-slate-muted">Matched</span>
          <.chip kind="keyword" size="compact">invoicing</.chip>
          <.chip kind="keyword" size="compact">EU VAT</.chip>
        </div>
      </div>

      <div class="flex max-w-[700px] flex-col gap-2.5">
        <.section_label>Your draft</.section_label>
        <.draft_box id="thread-draft">
          Founder of [YOUR PRODUCT] here, so weigh this accordingly. It does EU VAT invoices and nothing else, which sounds like what you are after. Happy to answer questions in this thread.
        </.draft_box>
      </div>

      <div class="flex max-w-[700px] flex-col gap-2.5">
        <.section_label>Who posts this one</.section_label>
        <.choice label="Who posts this one">
          <:option selected>You, from your account</:option>
        </.choice>
      </div>

      <div class="mt-1 flex flex-wrap gap-2.5">
        <.button surface="dark" size="main">Copy and open thread</.button>
        <.button variant="secondary" surface="dark" size="main">Edit draft</.button>
        <.button variant="quiet" surface="dark" size="main">Skip</.button>
      </div>
    </section>
    """
  end

  slot :inner_block, required: true

  defp section_label(assigns) do
    ~H"""
    <span class="font-mono text-[11px] uppercase tracking-[0.08em] text-on-slate-muted">
      {render_slot(@inner_block)}
    </span>
    """
  end

  defp example_threads do
    [
      %{
        subreddit: "r/smallbusiness",
        age: "2h ago",
        title: "Simple invoicing that handles EU VAT, without a full accounting suite?",
        intent: "recommendation",
        selected: true
      },
      %{
        subreddit: "r/freelance",
        age: "5h ago",
        title: "[COMPETITOR] doubled its price. What is everyone switching to?",
        intent: "competitor",
        selected: false
      },
      %{
        subreddit: "r/Entrepreneur",
        age: "9h ago",
        title: "How do you chase late invoices without sounding rude?",
        intent: "related",
        selected: false
      }
    ]
  end
end
