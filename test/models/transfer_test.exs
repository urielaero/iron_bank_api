defmodule IronBank.TransferTest do
  use IronBank.ModelCase

  alias IronBank.Transfer

  @valid_attrs %{amount: 1, user_id: "some", card_id: "some value", amount_now: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Transfer.changeset(%Transfer{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Transfer.changeset(%Transfer{}, @invalid_attrs)
    refute changeset.valid?
  end
end
