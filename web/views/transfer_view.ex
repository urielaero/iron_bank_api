defmodule IronBank.TransferView do
  use IronBank.Web, :view

  alias IronBank.Card
  alias IronBank.CardView
  alias IronBank.User
  alias IronBank.UserView

  def render("index.json", %{transfers: transfers}) do
    %{data: render_many(transfers, IronBank.TransferView, "transfer.json")}
  end

  def render("show.json", %{transfer: transfer}) do
    %{data: render_one(transfer, IronBank.TransferView, "transfer.json")}
  end

  def render("transfer.json", %{transfer: transfer}) do
    card = render_rel(transfer.card) 
    user = render_rel(transfer.user)
    %{id: transfer.id,
      amount: transfer.amount,
      card: card,
      user: user}
  end

  defp render_rel(%Card{} = card), do:  CardView.render("card.json", %{card: card}) 
  defp render_rel(%User{} = user), do:  UserView.render("user.json", %{user: user}) 
  defp render_rel(_), do: %{}
end
