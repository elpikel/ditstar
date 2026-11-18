defmodule DitstarWeb.PageController do
  use DitstarWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
