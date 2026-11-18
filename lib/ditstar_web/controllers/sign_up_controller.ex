defmodule DitstarWeb.SignUpController do
  use DitstarWeb, :controller

  alias Ditstar.Accounts
  alias DitstarWeb.PageHTML

  def create(conn, %{"user" => user_params} = params) do
    submitted_form = submitted_form_name(params)

    case Accounts.sign_up(user_params, &url(~p"/users/log-in/#{&1}")) do
      :ok ->
        conn
        |> put_flash(:signed_up, "Check your email. We sent you a sign-in link.")
        |> redirect(to: PageHTML.sign_up_form_path(submitted_form))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render_landing(submitted_form, changeset)

      {:error, _delivery_reason} ->
        conn
        |> put_status(:service_unavailable)
        |> put_flash(:error, "We couldn't send your sign-in email. Please try again in a minute.")
        |> render_landing(submitted_form, user_params)
    end
  end

  defp submitted_form_name(%{"form" => "closing"}), do: :closing
  defp submitted_form_name(_params), do: :hero

  defp render_landing(conn, submitted_form, changeset_or_params) do
    conn
    |> put_view(PageHTML)
    |> render(:home, sign_up_forms: PageHTML.sign_up_forms(submitted_form, changeset_or_params))
  end
end
