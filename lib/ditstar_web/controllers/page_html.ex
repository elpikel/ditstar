defmodule DitstarWeb.PageHTML do
  @moduledoc """
  Pages rendered by `DitstarWeb.PageController`, and the landing page's two
  sign-up forms, `:hero` and `:closing`.

  See the `page_html` directory for all templates available.
  """
  use DitstarWeb, :html

  embed_templates "page_html/*"

  @sign_up_form_names [:hero, :closing]

  @doc """
  Returns an empty form for each landing sign-up form, keyed by its name.
  """
  def sign_up_forms do
    Map.new(@sign_up_form_names, &{&1, to_form(%{}, as: :user)})
  end

  @doc """
  Returns the landing sign-up forms with the submitted one built from its
  changeset or params, so only that form shows the submitted email and errors.
  """
  def sign_up_forms(submitted_form_name, changeset_or_params) when submitted_form_name in @sign_up_form_names do
    Map.put(sign_up_forms(), submitted_form_name, to_form(changeset_or_params, as: :user))
  end

  @doc """
  Returns the landing page path that scrolls to the given sign-up form.
  """
  def sign_up_form_path(:hero), do: ~p"/"
  def sign_up_form_path(:closing), do: ~p"/" <> "#access"

  @doc """
  Renders the check-your-email confirmation shown in place of a sign-up form.
  """
  attr :id, :string, required: true
  attr :surface, :string, default: "light", values: ~w(light dark)
  slot :inner_block, required: true

  def sign_up_confirmation(assigns) do
    ~H"""
    <p
      id={@id}
      role="status"
      class={[
        "mt-2 flex w-full max-w-[480px] items-center justify-center gap-2.5 rounded-control border px-5 py-4 text-base font-medium",
        @surface == "light" && "border-line-strong bg-white text-ink",
        @surface == "dark" && "border-surface-slate-line-strong bg-charcoal-raised text-on-slate"
      ]}
    >
      <.icon name="hero-envelope" class="size-5 shrink-0" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  slot :inner_block, required: true

  defp star_trail(assigns) do
    ~H"""
    <span class="relative isolate inline-block whitespace-nowrap">
      <svg
        aria-hidden="true"
        viewBox="0 0 400 80"
        preserveAspectRatio="none"
        class="pointer-events-none absolute -left-[0.04em] -bottom-[0.05em] -z-10 h-[0.8em] w-[calc(100%+0.6em)] fill-accent-lime"
      >
        <path d="M4.1 69.9L10.3 70.9L16.5 71.7L22.6 72.2L28.6 72.1L34.6 71.4L40.6 70.2L46.6 68.6L52.7 66.9L58.9 65.2L65.2 64.0L71.7 63.3L78.1 63.4L84.6 64.2L90.9 65.4L97.0 66.8L103.1 68.0L109.1 69.0L115.0 69.5L120.8 69.5L126.8 69.1L132.8 68.2L138.8 67.1L145.0 66.0L151.3 65.0L157.7 64.4L164.0 64.1L170.4 64.3L176.8 64.8L183.0 65.7L189.2 66.8L195.4 67.8L201.4 68.7L207.3 69.2L213.3 69.3L219.2 69.0L225.1 68.2L231.1 67.1L237.3 65.9L243.5 64.7L249.9 63.7L256.3 63.3L262.8 63.5L269.2 64.3L275.6 65.5L281.8 67.0L287.9 68.3L293.8 69.4L299.7 70.0L305.5 70.0L311.4 69.5L317.3 68.4L323.4 67.1L329.6 65.7L335.9 64.6L339.8 61.5L346.1 52.0L352.5 44.0L359.0 37.2L365.4 31.4L371.8 26.6L378.3 22.6L384.9 19.8L391.4 18.1L398.0 17.6L398.0 22.4L392.3 23.1L386.5 25.0L380.7 27.9L374.9 31.7L369.0 36.5L363.2 42.2L357.3 48.8L351.4 56.5L345.4 65.6L336.9 72.3L330.9 73.4L324.8 74.7L318.6 76.1L312.3 77.2L305.8 77.8L299.3 77.8L292.9 77.1L286.5 76.0L280.3 74.5L274.2 73.1L268.2 72.0L262.3 71.3L256.5 71.1L250.6 71.5L244.7 72.3L238.6 73.5L232.4 74.8L226.1 75.9L219.8 76.8L213.4 77.1L207.0 77.0L200.6 76.4L194.3 75.5L188.1 74.5L182.0 73.4L176.0 72.6L170.0 72.0L164.1 71.9L158.2 72.1L152.2 72.8L146.1 73.7L140.0 74.8L133.8 75.9L127.5 76.8L121.1 77.3L114.7 77.3L108.2 76.7L101.9 75.7L95.6 74.4L89.5 73.0L83.5 71.9L77.6 71.1L71.8 70.8L65.9 70.9L59.9 71.6L53.8 72.6L47.6 73.7L41.3 74.8L35.0 75.5L28.6 75.6L22.4 75.1L16.2 74.1L10.0 72.7L3.9 71.1Z" />
      </svg>
      <.star_mark
        surface="dark"
        class="pointer-events-none absolute -right-[0.84em] bottom-[0.27em] size-[0.56em] [&_path]:stroke-ink [&_path]:stroke-[1] [&_path]:[stroke-linejoin:round]"
      />
      {render_slot(@inner_block)}
    </span>
    """
  end
end
