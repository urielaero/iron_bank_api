defmodule IronBank.UserTest do
  use IronBank.ModelCase

  alias IronBank.User

  @valid_attrs %{code: "asdasd", type: :executive, active: true, address: "some content", code: "some content", email: "some content", last_name: "some content", name: "some content", phone: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "create user with UserTypeEnum" do
    user = Repo.insert! %User{type: 0}
    Repo.get(User, user.id).type == :client

    changeset = User.changeset(%User{name: "uriel", email: "aero.uriel@gmail.com", code: "asdasdasldsad"}, %{"type" => "cashier"})
    user = Repo.insert! changeset
    assert user.type == :cashier
  end
end
