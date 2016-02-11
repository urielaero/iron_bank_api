defmodule IronBank.Card do
  use IronBank.Web, :model

  schema "cards" do
    #field :card_number, :string alias of id
    field :name, CardNameEnum
    field :active, :boolean, default: false
    field :type, CardTypeEnum
    
    belongs_to :user, IronBank.User

    timestamps
  end

  @required_fields ~w(type name)
  @optional_fields ~w(active)

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
