defmodule DitstarWeb.ResultsLive do
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
      current_page={:results}
      inbox_count={3}
      example_data
    >
      <div id="results" class="flex flex-col gap-7 px-10 pt-8 pb-12">
        <div class="flex flex-wrap items-center justify-between gap-4">
          <h1 class="text-[30px] font-extrabold tracking-[-0.03em]">Results</h1>
          <.button id="results-range" variant="secondary" surface="dark">
            <span>Last 30 days</span>
            <.icon name="hero-chevron-down" class="size-3.5 text-on-slate-muted" />
          </.button>
        </div>

        <.callout>
          r/smallbusiness brought the most signups this month. Worth watching more closely.
        </.callout>

        <div
          id="results-stats"
          class="grid grid-cols-[repeat(auto-fit,minmax(min(220px,100%),1fr))] gap-4"
        >
          <.stat_tile label="Replies posted" value={3} />
          <.stat_tile label="Visits from replies" value={68} />
          <.stat_tile label="Signups" value={4} highlight />
        </div>

        <.data_table id="results-table" rows={@replies}>
          <:col :let={reply} label="Reply" strong>{reply.title}</:col>
          <:col :let={reply} label="Subreddit" mono muted>{reply.subreddit}</:col>
          <:col :let={reply} label="Posted" muted>{reply.posted_on}</:col>
          <:col :let={reply} label="By" muted>{reply.posted_by}</:col>
          <:col :let={reply} label="Visits" numeric>{reply.visits}</:col>
          <:col :let={reply} label="Signups" numeric>
            <span class={signups_class(reply.signups)}>{reply.signups}</span>
          </:col>
        </.data_table>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :replies, example_replies())}
  end

  defp signups_class(0), do: "text-on-slate-2"
  defp signups_class(_signups), do: "font-medium text-accent-lime"

  defp example_replies do
    [
      %{
        title: "Simple invoicing that handles EU VAT",
        subreddit: "r/smallbusiness",
        posted_on: "12 Nov",
        posted_by: "You",
        visits: 41,
        signups: 3
      },
      %{
        title: "[COMPETITOR] doubled its price",
        subreddit: "r/freelance",
        posted_on: "9 Nov",
        posted_by: "You",
        visits: 18,
        signups: 1
      },
      %{
        title: "Chasing late invoices",
        subreddit: "r/Entrepreneur",
        posted_on: "5 Nov",
        posted_by: "Ditstar, labelled",
        visits: 9,
        signups: 0
      }
    ]
  end
end
