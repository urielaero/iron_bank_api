defmodule Mix.Tasks.Users do
  use Mix.Task

  alias IronBank.UserController
  alias IronBank.User
  alias IronBank.Repo

  @ldap_api Application.get_env(:iron_bank, :ldap_api)

  def run(_args) do
    @ldap_api.start_link
    Repo.start_link
    admin = Repo.insert! %User{name: "admin1", last_name: "super", email: "admin@iron_bank.com", type: 3}
    executive =  Repo.insert! %User{name: "executive1", last_name: "medio-super", email: "executive@iron_bank.com", type: 2}
    cashier =  Repo.insert! %User{name: "cashier1", last_name: "cajera", email: "cashier@iron_bank.com", type: 1}
    UserController.do_create_ldap(admin, "admin")
    UserController.do_create_ldap(executive, "executive")
    UserController.do_create_ldap(cashier, "cashier")
    #print_id(admin)
    #print_id(executive)
    #print_id(cashier)
  end


  defp print_id(user) do
    Mix.shell.info "#{user.name} #{user.id} #{user.type}"
  end
end
