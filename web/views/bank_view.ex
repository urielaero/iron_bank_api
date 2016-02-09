defmodule IronBank.BankView do
  use IronBank.Web, :view

  def render("index.json", %{banks: banks}) do
    %{data: render_many(banks, IronBank.BankView, "bank.json")}
  end

  def render("show.json", %{bank: bank}) do
    %{data: render_one(bank, IronBank.BankView, "bank.json")}
  end

  def render("bank.json", %{bank: bank}) do
    %{id: bank.id,
      name: bank.name,
      address: bank.address,
      phones: bank.phones,
      emails: bank.emails}
  end
end
