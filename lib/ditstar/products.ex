defmodule Ditstar.Products do
  @moduledoc """
  Products an Account sells and the watch lists Ditstar searches for each:
  Watched Subreddits, Keywords and Competitors. Every function takes the
  caller's Scope and only reaches Products in the Scope's Account.
  """

  import Ecto.Query

  alias Ditstar.Accounts.Account
  alias Ditstar.Accounts.Scope
  alias Ditstar.Products.Product
  alias Ditstar.Repo

  def list_products(%Scope{account: %Account{} = account}) do
    account
    |> products_in_account()
    |> order_by([product: product], asc: product.inserted_at, asc: product.id)
    |> Repo.all()
  end

  def get_product(%Scope{account: %Account{} = account}, id) do
    case Ecto.Type.cast(:id, id) do
      {:ok, product_id} ->
        account
        |> products_in_account()
        |> where([product: product], product.id == ^product_id)
        |> preload(^Product.watch_lists())
        |> Repo.one()

      :error ->
        nil
    end
  end

  def change_product(%Scope{} = scope, %Product{} = product, attrs \\ %{}) do
    product
    |> put_account(scope)
    |> preload_watch_lists()
    |> Product.changeset(attrs, allowed_default_posters())
  end

  def save_product(%Scope{} = scope, %Product{id: nil} = product, attrs) do
    scope
    |> change_product(product, attrs)
    |> Repo.insert()
  end

  def save_product(%Scope{account: %Account{id: account_id}} = scope, %Product{account_id: account_id} = product, attrs) do
    scope
    |> change_product(product, attrs)
    |> Repo.update()
  end

  def save_product(%Scope{}, %Product{}, _attrs), do: {:error, :not_found}

  def managed_posting_enabled? do
    Application.get_env(:ditstar, :managed_posting_enabled, false)
  end

  defp products_in_account(%Account{id: account_id}) do
    Product
    |> from(as: :product)
    |> where([product: product], product.account_id == ^account_id)
  end

  defp put_account(%Product{id: nil} = product, %Scope{account: %Account{id: account_id}}) do
    %{product | account_id: account_id}
  end

  defp put_account(%Product{} = product, %Scope{}), do: product

  defp preload_watch_lists(%Product{id: nil} = product), do: product

  defp preload_watch_lists(%Product{} = product) do
    Repo.preload(product, Product.watch_lists())
  end

  defp allowed_default_posters do
    if managed_posting_enabled?() do
      Product.default_posters()
    else
      List.delete(Product.default_posters(), :managed_account)
    end
  end
end
