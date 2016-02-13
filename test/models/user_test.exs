defmodule IronBank.UserTest do
  use IronBank.ModelCase

  alias IronBank.User

  @valid_attrs %{code: "asdasd", type: :executive, active: true, address: "some content", code: "some content", email: "some content", last_name: "some content last", name: "some content name", phone: "some content"}
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

    changeset = User.changeset(%User{name: "uriel", email: "aero.uriel@gmail.com", last_name: "last"}, %{"type" => "cashier"})
    user = Repo.insert! changeset
    assert user.type == :cashier
  end

  test "should format info for ldap user" do 
    changeset = User.changeset(%User{}, @valid_attrs)
    user = Repo.insert! changeset
    user_format = User.format_ldap(user)
    user_cn = to_char_list user.name
    user_last_name = to_char_list user.last_name
    assert user_format == %{
      cn: 'cn=#{user.id},ou=Users,dc=openstack,dc=org',
      attributes: [{'objectclass', ['person']},
      {'cn', [user_cn]},
      {'sn', [user_last_name]}]
    }
  end
end
