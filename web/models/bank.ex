defmodule IronBank.Bank do
  use IronBank.Web, :model

  schema "banks" do
    field :name, :string
    field :address, :string
    field :phones, :string
    field :emails, :string

    has_many :users, IronBank.User

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w(address phones emails)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
