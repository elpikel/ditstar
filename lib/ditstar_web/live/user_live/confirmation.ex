defmodule DitstarWeb.UserLive.Confirmation do
  @moduledoc false
  use DitstarWeb, :live_view

  alias Ditstar.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.auth flash={@flash}>
      <h1 class="text-[26px] font-extrabold tracking-[-0.03em] break-words">
        Welcome {@user.email}
      </h1>

      <.form
        :if={!@user.confirmed_at}
        for={@form}
        id="confirmation_form"
        phx-mounted={JS.focus_first()}
        phx-submit="submit"
        action={~p"/users/log-in?_action=confirmed"}
        phx-trigger-action={@trigger_submit}
        class="flex flex-col gap-2"
      >
        <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
        <.button
          type="submit"
          class="w-full"
          name={@form[:remember_me].name}
          value="true"
          phx-disable-with="Confirming..."
        >
          Confirm and stay logged in
        </.button>
        <.button type="submit" variant="quiet" class="w-full" phx-disable-with="Confirming...">
          Confirm and log in only this time
        </.button>
      </.form>

      <.form
        :if={@user.confirmed_at}
        for={@form}
        id="login_form"
        phx-submit="submit"
        phx-mounted={JS.focus_first()}
        action={~p"/users/log-in"}
        phx-trigger-action={@trigger_submit}
        class="flex flex-col gap-2"
      >
        <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
        <%= if @current_scope do %>
          <.button type="submit" class="w-full" phx-disable-with="Logging in...">
            Log in
          </.button>
        <% else %>
          <.button
            type="submit"
            class="w-full"
            name={@form[:remember_me].name}
            value="true"
            phx-disable-with="Logging in..."
          >
            Keep me logged in on this device
          </.button>
          <.button type="submit" variant="quiet" class="w-full" phx-disable-with="Logging in...">
            Log me in only this time
          </.button>
        <% end %>
      </.form>
    </Layouts.auth>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    if user = Accounts.get_user_by_magic_link_token(token) do
      form = to_form(%{"token" => token}, as: "user")

      {:ok, assign(socket, user: user, form: form, trigger_submit: false), temporary_assigns: [form: nil]}
    else
      {:ok,
       socket
       |> put_flash(:error, "Magic link is invalid or it has expired.")
       |> push_navigate(to: ~p"/users/log-in")}
    end
  end

  @impl true
  def handle_event("submit", %{"user" => params}, socket) do
    {:noreply, assign(socket, form: to_form(params, as: "user"), trigger_submit: true)}
  end
end
