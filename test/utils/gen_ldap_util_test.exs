defmodule Util.GenLdapTest do
  use ExUnit.Case

  alias Util.GenLdap

  @moduletag :genldap_api

  setup do
    {:ok, ldap} = GenLdap.start_link
    {:ok, ldap: ldap}
  end

  test "spawn gen server", %{ldap: ldap} do
    assert Process.alive? ldap
  end

  test "check if ldap pid is alive" do
    assert GenLdap.alive? == true
  end

  test "check simple_bind" do
    user = Application.get_env(:iron_bank, :cn_admin) 
    pass = Application.get_env(:iron_bank, :cn_password) 
    assert GenLdap.simple_bind(user, pass) == :ok
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

  test "failed to update with bad old password" do
    cn = 'cn=54da3fde31f40c76004324c9,ou=Users,dc=openstack,dc=org'
    password = 'bad password'
    update_password = 'algo2'
    assert GenLdap.set_password(cn, password, update_password) == {:error, {:response, :unwillingToPerform}}
    assert GenLdap.set_password(cn, 'lolol') == :ok
  end

  test "update password" do
    cn = 'cn=54da3fde31f40c76004324c9,ou=Users,dc=openstack,dc=org'
    password = 'lolol'
    update_password = 'algo2'
    assert GenLdap.set_password(cn, password, update_password) == :ok
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
