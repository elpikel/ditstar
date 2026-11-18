defmodule Ditstar.Accounts.Scope do
  @moduledoc """
  Defines the scope of the caller to be used throughout the app.

  The `Ditstar.Accounts.Scope` allows public interfaces to receive
  information about the caller, such as if the call is initiated from an
  end-user, and if so, which user. Additionally, such a scope can carry fields
  such as "super user" or other privileges for use in authorization checks,
  or to ensure specific code paths can only be accessed for a given scope.

  It is useful for logging as well as for scoping pubsub subscriptions and
  broadcasts when a caller subscribes to an interface or performs a particular
  action.

  Feel free to extend the fields on this struct to fit the needs of
  growing application requirements.
  """

  alias Ditstar.Accounts.Account
  alias Ditstar.Accounts.User

  defstruct user: nil, account: nil

  @doc """
  Creates a scope for the given user acting in the given Account.
  """
  def for_user(%User{} = user, %Account{} = account) do
    %__MODULE__{user: user, account: account}
  end
end
