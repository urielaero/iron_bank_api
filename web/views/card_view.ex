defmodule IronBank.CardView do
  use IronBank.Web, :view

  def render("index.json", %{cards: cards}) do
    %{data: render_many(cards, IronBank.CardView, "card.json")}
  end

  def render("show.json", %{card: card}) do
    %{data: render_one(card, IronBank.CardView, "card.json")}
  end

  def render("card.json", %{card: card}) do
    %{id: card.id,
      type: card.type,
      card_number: card.id,
      name: card.name,
      amount: card.amount,
      user_id: card.user_id,
      active: card.active}
  end
end
