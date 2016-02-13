defmodule IronBank.User do
  use IronBank.Web, :model

  schema "users" do
    field :name, :string
    field :last_name, :string
    field :email, :string
    field :address, :string
    field :phone, :string
    #field :code, :string
    field :active, :boolean, default: true
    field :type, UserTypeEnum

    belongs_to :bank, IronBank.Bank

    has_many :cards, IronBank.Card

    timestamps
  end

  @required_fields ~w(name email type last_name)
  @optional_fields ~w(address phone active)


  @ldap_context Application.get_env(:iron_bank, :ldap_context)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end



  def format_ldap(%IronBank.User{id: id, name: name, last_name: last_name}) do
    cn = 'cn=#{id},#{@ldap_context}'
    ch_name = to_char_list(name)
    ch_last_name = to_char_list(last_name)
    attributes = [{'objectclass', ['person']},
      {'cn', [ch_name]},
      {'sn', [ch_last_name]}]

    %{cn: cn, attributes: attributes}
  end
end
