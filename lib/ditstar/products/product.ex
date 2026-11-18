defmodule Ditstar.Products.Product do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Ditstar.Accounts.Account
  alias Ditstar.Products.Competitor
  alias Ditstar.Products.Keyword
  alias Ditstar.Products.WatchedSubreddit

  @default_posters [:own_account, :managed_account]

  @watch_lists [
    %{assoc: :watched_subreddits, field: :name},
    %{assoc: :keywords, field: :term},
    %{assoc: :competitors, field: :name}
  ]

  schema "products" do
    belongs_to :account, Account
    field :name, :string
    field :website, :string
    field :description, :string
    field :default_poster, Ecto.Enum, values: @default_posters, default: :own_account

    has_many :watched_subreddits, WatchedSubreddit, on_replace: :delete, preload_order: [asc: :id]
    has_many :keywords, Keyword, on_replace: :delete, preload_order: [asc: :id]
    has_many :competitors, Competitor, on_replace: :delete, preload_order: [asc: :id]

    timestamps(type: :utc_datetime)
  end

  def default_posters, do: @default_posters

  def watch_lists, do: Enum.map(@watch_lists, & &1.assoc)

  def changeset(%__MODULE__{} = product, attrs, allowed_default_posters) do
    product
    |> cast(attrs, [:name, :website, :description, :default_poster])
    |> update_change(:name, &String.trim/1)
    |> update_change(:website, &String.trim/1)
    |> update_change(:description, &String.trim/1)
    |> validate_required([:name, :default_poster])
    |> validate_length(:name, max: 255)
    |> validate_inclusion(:default_poster, allowed_default_posters)
    |> cast_watch_lists()
    |> validate_watch_lists_have_no_duplicates()
  end

  defp cast_watch_lists(changeset) do
    Enum.reduce(@watch_lists, changeset, fn %{assoc: assoc}, changeset ->
      cast_assoc(changeset, assoc,
        sort_param: :"#{assoc}_sort",
        drop_param: :"#{assoc}_drop"
      )
    end)
  end

  defp validate_watch_lists_have_no_duplicates(changeset) do
    Enum.reduce(@watch_lists, changeset, fn watch_list, changeset ->
      validate_no_duplicate_entries(changeset, watch_list)
    end)
  end

  defp validate_no_duplicate_entries(changeset, %{assoc: assoc, field: field}) do
    case Map.fetch(changeset.changes, assoc) do
      {:ok, entries} ->
        checked_entries = mark_duplicate_entries(entries, field)

        %{
          changeset
          | changes: Map.put(changeset.changes, assoc, checked_entries),
            valid?: changeset.valid? and Enum.all?(checked_entries, & &1.valid?)
        }

      :error ->
        changeset
    end
  end

  defp mark_duplicate_entries(entries, field) do
    {checked_entries, _seen_values} =
      Enum.map_reduce(entries, MapSet.new(), fn entry, seen_values ->
        mark_duplicate_entry(entry, field, seen_values)
      end)

    checked_entries
  end

  defp mark_duplicate_entry(%Ecto.Changeset{action: action} = entry, _field, seen_values)
       when action in [:replace, :delete] do
    {entry, seen_values}
  end

  defp mark_duplicate_entry(entry, field, seen_values) do
    case get_field(entry, field) do
      value when is_binary(value) ->
        comparable_value = String.downcase(value)

        if MapSet.member?(seen_values, comparable_value) do
          {add_error(entry, field, "has already been added"), seen_values}
        else
          {entry, MapSet.put(seen_values, comparable_value)}
        end

      _blank ->
        {entry, seen_values}
    end
  end
end
