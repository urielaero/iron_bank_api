defmodule IronBank.Transfer do
  use IronBank.Web, :model

  import Ecto.Query

  schema "transfers" do
    field :amount, :float
    field :amount_now, :float
    belongs_to :user, IronBank.User
    belongs_to :card, IronBank.Card

    timestamps
  end

  @required_fields ~w(amount user_id card_id amount_now)
  @optional_fields ~w()

  @preload_rels [:user, :card]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def filter_by_card_id(query, nil), do: query
  def filter_by_card_id(query, card_id) do
    from transfer in query,
      where: transfer.card_id == ^card_id
  end

  def filter_by_user_id(query, user_id) do
    from transfer in query,
      where: transfer.user_id == ^user_id
  end

  def filter_by_date(query, month, year) do
    {:ok, date_from} = Ecto.Date.cast "#{year}-#{month}-01"
    i_year = String.to_integer year
    i_month = String.to_integer month
    last_day = :calendar.last_day_of_the_month(i_year, i_month)
    {:ok, date_to} = Ecto.Date.cast "#{year}-#{month}-#{last_day}"
    date_from_time = Ecto.DateTime.from_date(date_from)
    date_to_time = Ecto.DateTime.from_date(date_to)
    from transfer in query, 
      where: transfer.inserted_at >= ^date_from_time and transfer.inserted_at <= ^date_to_time
  end

  def preload(query) do
    preload(query, ^@preload_rels)
  end
end
