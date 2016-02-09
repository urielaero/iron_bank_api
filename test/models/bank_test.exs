defmodule IronBank.BankTest do
  use IronBank.ModelCase

  alias IronBank.Bank

  @valid_attrs %{address: "some content", emails: "some content", name: "some content", phones: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Bank.changeset(%Bank{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Bank.changeset(%Bank{}, @invalid_attrs)
    refute changeset.valid?
  end
end
