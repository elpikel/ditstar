defmodule DitstarWeb.UserLive.Login do
  @moduledoc false
  use DitstarWeb, :live_view

  alias Ditstar.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.auth flash={@flash}>
      <div class="flex flex-col gap-2">
        <h1 class="text-[26px] font-extrabold tracking-[-0.03em]">Log in</h1>
        <p :if={@current_scope} class="text-[15px] text-body">
          You need to reauthenticate to perform sensitive actions on your account.
        </p>
        <p :if={!@current_scope} class="text-[15px] text-body">
          We'll email you a sign-in link. No account yet?
          <.link href={~p"/#access"} class="font-semibold text-ink underline">Create one</.link>
        </p>
      </div>

      <p
        :if={local_mail_adapter?()}
        id="local-mail-adapter-notice"
        class="rounded-control bg-page-alt px-4 py-3 text-[13px] text-body"
      >
        You are running the local mail adapter. To see sent emails, visit <.link
          href="/dev/mailbox"
          class="underline"
        >the mailbox page</.link>.
      </p>

      <.form
        :let={f}
        for={@form}
        id="login_form_magic"
        action={~p"/users/log-in"}
        phx-submit="submit_magic"
        class="flex flex-col gap-4"
      >
        <.text_input
          readonly={!!@current_scope}
          field={f[:email]}
          type="email"
          label="Email"
          autocomplete="username"
          spellcheck="false"
          required
          phx-mounted={JS.focus()}
        />
        <.button type="submit" class="w-full">
          Log in with email <span aria-hidden="true">→</span>
        </.button>
      </.form>

      <details id="login-with-password" class="border-t border-line pt-4">
        <summary class="cursor-pointer text-[13px] text-body-muted">
          Use a password instead
        </summary>
        <.form
          :let={f}
          for={@form}
          id="login_form_password"
          action={~p"/users/log-in"}
          phx-submit="submit_password"
          phx-trigger-action={@trigger_submit}
          class="mt-4 flex flex-col gap-4"
        >
          <.text_input
            readonly={!!@current_scope}
            field={f[:email]}
            type="email"
            label="Email"
            autocomplete="username"
            spellcheck="false"
            required
          />
          <.text_input
            field={f[:password]}
            type="password"
            label="Password"
            autocomplete="current-password"
            spellcheck="false"
          />
          <.button
            type="submit"
            variant="secondary"
            class="w-full"
            name={@form[:remember_me].name}
            value="true"
          >
            Log in and stay logged in
          </.button>
          <.button type="submit" variant="quiet" class="w-full">
            Log in only this time
          </.button>
        </.form>
      </details>
    </Layouts.auth>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end

  def handle_event("submit_magic", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_login_instructions(
        user,
        &url(~p"/users/log-in/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions for logging in shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> push_navigate(to: ~p"/users/log-in")}
  end

  defp local_mail_adapter? do
    Application.get_env(:ditstar, Ditstar.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
