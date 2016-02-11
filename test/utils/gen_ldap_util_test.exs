defmodule Util.GenLdapTest do
  use ExUnit.Case

  alias Util.GenLdap

  @moduletag :genldap_api

  @cn_admin Application.get_env(:iron_bank, :cn_admin)
  @cn_password Application.get_env(:iron_bank, :cn_password)

  setup do
    {:ok, ldap} = GenLdap.start_link(@cn_admin, @cn_password)
    {:ok, ldap: ldap}
  end

  test "spawn gen server", %{ldap: ldap} do
    assert Process.alive? ldap
  end

  test "check if ldap pid is alive" do
    assert GenLdap.alive? == true
  end

  test "check simple_bind" do
    assert GenLdap.simple_bind("cn=admin,dc=openstack,dc=org", "password") == :ok
  end

  test "create user " do
    cn = 'cn=54da3fde31f40c76004324c9,ou=Users,dc=openstack,dc=org'
    attributes = [{'objectclass', ['person']},
      {'cn', ['Bill Valentine']},
      {'sn', ['last name']}]

    res = GenLdap.create cn, attributes
    case res do
      :ok -> true
      {:error, :entryAlreadyExists} -> true
      _ -> throw res
    end
  end

  test "set password" do
    cn = 'cn=54da3fde31f40c76004324c9,ou=Users,dc=openstack,dc=org'
    password = 'lolol'
    assert GenLdap.set_password(cn, password) == :ok
  end

  test "verify user password" do
    cn = 'cn=Antony Tzel ADot Ciau,ou=Users,dc=openstack,dc=org'
    bad_password = 'yolo'
    password = 'lolol'
    assert GenLdap.verify(cn, bad_password) == false
    assert GenLdap.verify(cn, password) == true
  end

  test "should stop gen_server and close conecction the open pid", %{ldap: pid} do
    GenLdap.stop(pid)
    assert GenLdap.alive? == false
  end
end
