defmodule Util.GenLdap do

  use GenServer

  def start_link do
    cn_admin = Application.get_env(:iron_bank, :cn_admin) 
    password = Application.get_env(:iron_bank, :cn_password) 
    GenServer.start_link(__MODULE__, {:ok, cn_admin, password}, name: __MODULE__)
  end

  #client
  
  def alive? do
    GenServer.call(__MODULE__, :alive?)
  end

  def create(cn, attributes) do
    GenServer.call(__MODULE__, {:create, cn, attributes})
  end

  def set_password(cn, password) do
    GenServer.call(__MODULE__, {:set_password, cn, password})
  end

  def set_password(cn, old_password, new_password) do
    GenServer.call(__MODULE__, {:set_password, cn, old_password, new_password })
  end

  def simple_bind(cn, password) do
    GenServer.call(__MODULE__, {:simple_bind, cn, password})
  end

  def stop(_pid) do
    GenServer.call(__MODULE__, :stop)
  end

  def verify(cn, password) do
    case GenServer.call(__MODULE__, {:simple_bind, cn, password}) do
      {:error, _} -> false
      :ok -> true
    end
  end

  # callbacks
  def init({:ok, cn_admin, password}) do
    host =  Application.get_env(:iron_bank, :ldap_host, "localhost") 
    port = 389
    case :eldap.open([to_char_list(host), port: port]) do
      {:ok, pid} -> {:ok, %{pid: pid, cn_admin: cn_admin, password: password}}
      {:error, reason} -> {:error, reason}
    end
  end

  def handle_call(:alive?, _from, %{pid: pid} = ldap) do
    status = Process.alive? pid
    {:reply, status, ldap}
  end

  def handle_call(:alive?, _from, _ldap) do
    {:reply, false, %{}}
  end

  def handle_call({:simple_bind, cn, password}, _from, %{pid: pid} = ldap) do
    bind = :eldap.simple_bind(pid, cn, password)
    {:reply, bind, ldap}
  end

  def handle_call({:create, cn, attributes}, _from, %{pid: pid, 
                  cn_admin: cn_admin, 
                  password: password_admin} = ldap) do

    :eldap.simple_bind(pid, cn_admin, password_admin)
    res = :eldap.add(pid, cn, attributes)
    #IO.inspect res
    {:reply, res, ldap}
  end

  def handle_call({:set_password, cn, password}, _from, %{pid: pid, 
                  cn_admin: cn_admin, 
                  password: password_admin} = ldap) do

    :eldap.simple_bind(pid, cn_admin, password_admin)
    res = :eldap.modify_password(pid, cn, password)
    {:reply, res, ldap}
  end

  def handle_call({:set_password, cn, old_password, new_password}, _from, %{pid: pid, 
                  cn_admin: cn_admin, 
                  password: password_admin} = ldap) do

    :eldap.simple_bind(pid, cn_admin, password_admin)
    res = :eldap.modify_password(pid, cn, new_password, old_password)
    {:reply, res, ldap}
  end

  def handle_call(:stop, _from, %{pid: pid}) do
    case :eldap.close(pid) do
      :ok -> {:reply, true, %{}}
      {:error, reason} -> {:reply, reason, %{}}
    end
  end

end

defmodule Util.GenLdap.InMemory do

  def start_link do
    init = restore
    Agent.start_link(fn -> 
      init
    end, name: __MODULE__)
  end

  def set_password(cn, password) do
    file_name = "test_pass.txt"
    {stat, body} = File.read(file_name)
    if stat != :ok do
      body = ""
    end
    
    {:ok, file} = File.open(file_name, [:write])
    IO.write file, "#{body}\n#{cn}|#{password}"
    File.close(file)

    Agent.update(__MODULE__, &(Dict.put(&1, cn, password)))
  end

  def set_password(cn, password, new_password) do
    file_name = "test_pass_update.txt"
    {stat, body} = File.read(file_name)
    if stat != :ok do
      body = ""
    end
    
    {:ok, file} = File.open(file_name, [:write])
    IO.write file, "#{body} \n #{cn},#{password},#{new_password}"
    File.close(file)
    if verify(cn, password), do: Agent.update(__MODULE__, &(Dict.put(&1, cn, password))), else: false
  end

  def verify(cn, password) do
    Agent.get(__MODULE__, fn pass -> 
      user_pass = Dict.get(pass, cn)
      password == user_pass
    end)

  end

  def create(_cn, _attributes) do
    :ok
  end
  
  defp restore() do
    {stat, body} = File.read("test_pass.txt")
    ldap = %{}
    if stat == :ok do
      lines = String.split body, "\n"
      rest = Enum.reduce(lines, ldap, fn (l,acc) -> 
          case String.split l, "|" do
            [cn, password] -> 
              cn_binary = to_char_list cn
              pass_binary = to_char_list password
              Dict.put(acc, cn_binary, pass_binary)
            _ -> acc
          end
      end)
      rest
    else 
      ldap
    end

  end
end
