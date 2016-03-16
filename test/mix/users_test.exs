defmodule Mix.Tasks.UsersTest do
  use ExUnit.Case, async: true

  alias Mix.Tasks.Users
  alias IronBank.Repo
  alias IronBank.User

  @ldap_api Application.get_env(:iron_bank, :ldap_api)
  
  def verify(user, password) do
    ldap = User.format_ldap(user)
    ch_password = to_char_list(password)
    @ldap_api.verify(ldap.cn, ch_password)
  end

  test "should create admin, executive and cashier users" do
    Users.run([])
    cashier = Repo.get_by!(User, name: "cashier1", type: 1)
    executive = Repo.get_by!(User, name: "executive1", type: 2)
    admin = Repo.get_by!(User, name: "admin1", type: 3)
    assert verify(cashier, "cashier")
    assert verify(executive, "executive")
    assert verify(admin, "admin")
    refute verify(cashier, "cashie")
    refute verify(executive, "ex")
    refute verify(admin, "other")
  end
end
