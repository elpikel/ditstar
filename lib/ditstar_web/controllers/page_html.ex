defmodule DitstarWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use DitstarWeb, :html

  embed_templates "page_html/*"
end
