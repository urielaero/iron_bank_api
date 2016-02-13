defmodule IronBank.UserView do
  use IronBank.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, IronBank.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, IronBank.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      name: user.name,
      last_name: user.last_name,
      email: user.email,
      address: user.address,
      phone: user.phone,
      code: user.id,
      type: user.type,
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
end
