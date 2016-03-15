defmodule IronBank.UserView do
  use IronBank.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, IronBank.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, IronBank.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    cards = render_cards(user.cards)
    %{id: user.id,
      name: user.name,
      last_name: user.last_name,
      email: user.email,
      address: user.address,
      phone: user.phone,
      code: user.id,
      type: user.type,
      cards: cards,
      active: user.active}
  end


  def render("user_login.json", %{user: user, token: token}) do
    %{data: 
      %{id: user.id,
        name: user.name,
        last_name: user.last_name,
        email: user.email,
        address: user.address,
        phone: user.phone,
        code: user.id,
        type: user.type,
        token: token,
        active: user.active}
    }
  end

  defp render_cards([head|tail]) do
    [%{
      active: head.active,
      type: head.type,
      amount: head.amount,
      name: head.name,
      id: head.id,
      card_number: head.id
    } | render_cards(tail)]
  end
  defp render_cards(_cards), do: []
end
