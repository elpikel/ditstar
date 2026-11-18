defmodule Ditstar.Accounts.Account do
  @moduledoc false
  use Ecto.Schema

  alias Ditstar.Accounts.Membership

  schema "accounts" do
    has_many :memberships, Membership

    timestamps(type: :utc_datetime)
  end
end
