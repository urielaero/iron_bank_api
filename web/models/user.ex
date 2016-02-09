defmodule IronBank.User do
  use IronBank.Web, :model

  schema "users" do
    field :name, :string
    field :last_name, :string
    field :email, :string
    field :address, :string
    field :phone, :string
    field :code, :string
    field :active, :boolean, default: false
    field :type, UserTypeEnum

    belongs_to :bank, IronBank.Bank

    has_many :cards, IronBank.Card

    timestamps
  end

  @required_fields ~w(name email code type)
  @optional_fields ~w(name last_name address phone code active)

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
