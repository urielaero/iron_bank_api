defmodule IronBank.CardTest do
  use IronBank.ModelCase

  alias IronBank.Card

  @valid_attrs %{active: true, card_number: "some content", name: :oro, type: :debit}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Card.changeset(%Card{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Card.changeset(%Card{}, @invalid_attrs)
    refute changeset.valid?
  end
end
