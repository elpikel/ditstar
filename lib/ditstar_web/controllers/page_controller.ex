defmodule DitstarWeb.PageController do
  use DitstarWeb, :controller

  alias DitstarWeb.PageHTML

  def home(conn, _params) do
    render(conn, :home, sign_up_forms: PageHTML.sign_up_forms())
  end
end
