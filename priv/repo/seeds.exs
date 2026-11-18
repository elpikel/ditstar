# Seeds a dev user, their Account and one Product. Safe to run more than once.
#
#     mix run priv/repo/seeds.exs

alias Ditstar.Accounts
alias Ditstar.Accounts.Scope
alias Ditstar.Accounts.User
alias Ditstar.Products
alias Ditstar.Products.Product
alias Ditstar.Repo

dev_email = "dev@ditstar.local"

dev_user =
  case Accounts.get_user_by_email(dev_email) do
    %User{} = existing_user ->
      existing_user

    nil ->
      {:ok, registered_user} = Accounts.register_user(%{email: dev_email})
      registered_user
  end

dev_user =
  case dev_user do
    %User{confirmed_at: nil} -> dev_user |> User.confirm_changeset() |> Repo.update!()
    %User{} -> dev_user
  end

scope = Scope.for_user(dev_user, Accounts.account_for_user(dev_user))

if Products.list_products(scope) == [] do
  {:ok, %Product{}} =
    Products.save_product(scope, %Product{}, %{
      name: "Ditstar",
      website: "https://ditstar.local",
      description: "Finds Reddit threads where people ask for a product like yours.",
      watched_subreddits: [%{name: "SaaS"}, %{name: "startups"}],
      keywords: [%{term: "reddit marketing tool"}, %{term: "find customers on reddit"}],
      competitors: [%{name: "Example Competitor"}]
    })
end

IO.puts("Seeded #{dev_email}: sign in at /users/log-in with that email, then open the magic link from /dev/mailbox.")
