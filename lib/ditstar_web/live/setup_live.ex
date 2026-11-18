defmodule DitstarWeb.SetupLive do
  @moduledoc false
  use DitstarWeb, :live_view

  alias Ditstar.Products
  alias Ditstar.Products.Product
  alias Phoenix.LiveView.JS

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      current_product={@current_product}
      products={@products}
      current_page={:setup}
    >
      <div id="setup" class="flex flex-col gap-7 px-10 pt-8 pb-12">
        <div class="flex flex-col gap-2">
          <h1 class="text-[30px] font-extrabold tracking-[-0.03em]">Setup</h1>
          <p class="text-base text-on-slate-2">
            Tell Ditstar what you sell and where to look. Three steps, and you can change them any time.
          </p>
        </div>

        <.form
          for={@form}
          id="setup-form"
          phx-change="validate"
          phx-submit="save"
          class="flex flex-col gap-7"
        >
          <.setup_card id="setup-product" step="01" title="Your product">
            <div class="grid grid-cols-[repeat(auto-fit,minmax(min(260px,100%),1fr))] gap-4">
              <.text_input
                field={@form[:name]}
                label="Name"
                variant="slate"
                placeholder="[YOUR PRODUCT]"
              />
              <.text_input
                field={@form[:website]}
                type="url"
                label="Website"
                variant="slate"
                placeholder="https://"
              />
            </div>
            <.text_input
              field={@form[:description]}
              label="What it does, in a sentence or two"
              variant="slate"
              placeholder="Ditstar uses this when it drafts your replies"
            />
          </.setup_card>

          <.setup_card id="setup-where-to-look" step="02" title="Where to look">
            <.watch_list :for={watch_list <- watch_lists()} form={@form} watch_list={watch_list} />
          </.setup_card>

          <.setup_card id="setup-who-posts" step="03" title="Who posts by default">
            <input
              type="hidden"
              name={@form[:default_poster].name}
              value={@form[:default_poster].value}
            />
            <.choice label="Who posts by default" variant="card">
              <:option
                :for={poster <- default_poster_options(@managed_posting_enabled?)}
                id={"default-poster-#{poster.value}"}
                selected={to_string(@form[:default_poster].value) == to_string(poster.value)}
                description={poster.description}
                phx-click="select_default_poster"
                phx-value-poster={poster.value}
              >
                {poster.title}
              </:option>
            </.choice>
          </.setup_card>

          <div class="flex flex-wrap gap-2.5">
            <.button type="submit" surface="dark" size="main" id="setup-save">
              Save and start watching
            </.button>
          </div>
        </.form>

        <.form
          for={%{}}
          id="setup-current-product-form"
          action={~p"/app/current-product"}
          method="put"
          phx-trigger-action={@trigger_submit}
          class="hidden"
        >
          <input type="hidden" name="product_id" value={@created_product_id} />
          <input type="hidden" name="after" value="inbox" />
        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    changeset =
      Products.change_product(
        socket.assigns.current_scope,
        product_to_set_up(socket.assigns.live_action, socket.assigns.current_product)
      )

    {:ok,
     socket
     |> assign(
       product: changeset.data,
       managed_posting_enabled?: Products.managed_posting_enabled?(),
       created_product_id: nil,
       trigger_submit: false
     )
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    {:noreply, assign_validated_form(socket, product_params)}
  end

  def handle_event("select_default_poster", %{"poster" => poster}, socket) do
    product_params = Map.put(socket.assigns.form.params, "default_poster", poster)
    {:noreply, assign_validated_form(socket, product_params)}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    case Products.save_product(socket.assigns.current_scope, socket.assigns.product, product_params) do
      {:ok, %Product{} = saved_product} ->
        {:noreply, after_save(socket, saved_product)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  attr :id, :string, required: true
  attr :step, :string, required: true
  attr :title, :string, required: true
  slot :inner_block, required: true

  defp setup_card(assigns) do
    ~H"""
    <section
      id={@id}
      aria-labelledby={"#{@id}-title"}
      class="flex max-w-[780px] flex-col gap-5 rounded-card border border-surface-slate-line p-7"
    >
      <div class="flex items-baseline gap-3">
        <span class="font-mono text-xs text-accent-lime">{@step}</span>
        <h2 id={"#{@id}-title"} class="text-xl font-bold tracking-[-0.01em]">{@title}</h2>
      </div>
      {render_slot(@inner_block)}
    </section>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true
  attr :watch_list, :map, required: true

  defp watch_list(assigns) do
    ~H"""
    <div id={"setup-#{@watch_list.assoc}"} class="flex flex-col gap-2.5">
      <span id={"setup-#{@watch_list.assoc}-label"} class="text-[13px] font-medium text-on-slate-2">
        {@watch_list.label}
      </span>
      <div
        role="group"
        aria-labelledby={"setup-#{@watch_list.assoc}-label"}
        class="flex flex-wrap items-center gap-2"
      >
        <.inputs_for :let={entry} field={@form[@watch_list.assoc]}>
          <input
            type="hidden"
            name={list_param_name(@form, @watch_list.sort_param)}
            value={entry.index}
          />
          <.watch_list_entry
            field={entry[@watch_list.field]}
            index={entry.index}
            watch_list={@watch_list}
            drop_param_name={list_param_name(@form, @watch_list.drop_param)}
          />
        </.inputs_for>
        <input type="hidden" name={list_param_name(@form, @watch_list.drop_param)} />
        <.chip
          kind="add"
          name={list_param_name(@form, @watch_list.sort_param)}
          value="new"
          phx-click={JS.dispatch("change")}
        >
          {@watch_list.add_label}
        </.chip>
      </div>
    </div>
    """
  end

  attr :field, Phoenix.HTML.FormField, required: true
  attr :index, :integer, required: true
  attr :watch_list, :map, required: true
  attr :drop_param_name, :string, required: true

  defp watch_list_entry(%{field: field} = assigns) do
    errors = if used_input?(field), do: Enum.map(field.errors, &translate_error/1), else: []

    assigns =
      assign(assigns,
        errors: errors,
        error_id: errors != [] && "#{field.id}-error",
        display_value: field.value || ""
      )

    ~H"""
    <.chip kind={@watch_list.chip_kind} class={@errors != [] && "ring-[1.5px] ring-warn"}>
      <span class="inline-flex items-center">
        <label for={@field.id} class="sr-only">{@watch_list.entry_label}</label>
        <span :if={subreddit_prefix?(@watch_list, @display_value)} aria-hidden="true">r/</span>
        <input
          type="text"
          id={@field.id}
          name={@field.name}
          value={@display_value}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@error_id}
          placeholder={@watch_list.placeholder}
          class={[
            "min-w-[4ch] border-0 bg-transparent p-0 font-mono text-[13px] text-current [field-sizing:content] placeholder:text-current placeholder:opacity-70",
            @watch_list.chip_kind == "keyword" && "focus-visible:outline-on-accent"
          ]}
        />
      </span>
      <:remove
        label={remove_label(@watch_list, @display_value)}
        name={@drop_param_name}
        value={@index}
        phx-click={JS.dispatch("change")}
      />
    </.chip>
    <p
      :if={@errors != []}
      id={@error_id}
      class="order-last flex w-full items-center gap-1.5 text-[13px] text-warn"
    >
      <.icon name="hero-exclamation-circle" class="size-4" />
      {error_subject(@watch_list, @display_value)} {Enum.join(@errors, ", ")}
    </p>
    """
  end

  defp product_to_set_up(:edit, %Product{} = current_product), do: current_product
  defp product_to_set_up(_live_action, _current_product), do: %Product{}

  defp after_save(%{assigns: %{product: %Product{id: nil}}} = socket, %Product{id: created_product_id}) do
    assign(socket, created_product_id: created_product_id, trigger_submit: true)
  end

  defp after_save(socket, %Product{}), do: push_navigate(socket, to: ~p"/app")

  defp assign_validated_form(socket, product_params) do
    changeset =
      socket.assigns.current_scope
      |> Products.change_product(socket.assigns.product, product_params)
      |> Map.put(:action, :validate)

    assign_form(socket, changeset)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp remove_label(%{entry_label: entry_label}, ""), do: "Remove empty #{String.downcase(entry_label)}"
  defp remove_label(_watch_list, value), do: "Remove #{value}"

  defp error_subject(%{entry_label: entry_label}, ""), do: entry_label
  defp error_subject(_watch_list, value), do: value

  defp list_param_name(form, param), do: form[param].name <> "[]"

  defp subreddit_prefix?(%{assoc: :watched_subreddits}, value), do: not String.match?(value, ~r{^/?r/}i)
  defp subreddit_prefix?(_watch_list, _value), do: false

  defp watch_lists do
    [
      %{
        assoc: :watched_subreddits,
        field: :name,
        sort_param: :watched_subreddits_sort,
        drop_param: :watched_subreddits_drop,
        label: "Subreddits",
        entry_label: "Subreddit",
        add_label: "+ Add subreddit",
        chip_kind: "subreddit",
        placeholder: nil
      },
      %{
        assoc: :keywords,
        field: :term,
        sort_param: :keywords_sort,
        drop_param: :keywords_drop,
        label: "Keywords",
        entry_label: "Keyword",
        add_label: "+ Add keyword",
        chip_kind: "keyword",
        placeholder: nil
      },
      %{
        assoc: :competitors,
        field: :name,
        sort_param: :competitors_sort,
        drop_param: :competitors_drop,
        label: "Competitors to listen for",
        entry_label: "Competitor",
        add_label: "+ Add competitor",
        chip_kind: "competitor",
        placeholder: "[COMPETITOR]"
      }
    ]
  end

  defp default_poster_options(managed_posting_enabled?) do
    Enum.filter(
      [
        %{
          value: :own_account,
          title: "You post",
          description: "From your own Reddit account. Ditstar opens the thread with the draft copied."
        },
        %{
          value: :managed_account,
          title: "Ditstar posts, labelled",
          description:
            "From an account Ditstar runs. Every reply says it is a paid placement, and you approve each draft."
        }
      ],
      &(managed_posting_enabled? or &1.value != :managed_account)
    )
  end
end
