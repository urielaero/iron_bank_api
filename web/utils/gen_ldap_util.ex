defmodule Util.GenLdap do

  use GenServer

  def start_link(cn_admin, password) do
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
    #TODO implementar el supervisor tree.
    host = "localhost"
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
    {:reply, res, ldap}
  end

  def handle_call({:set_password, cn, password}, _from, %{pid: pid, 
                  cn_admin: cn_admin, 
                  password: password_admin} = ldap) do

    :eldap.simple_bind(pid, cn_admin, password_admin)
    res = :eldap.modify_password(pid, cn, password)
    {:reply, res, ldap}
  end

  def handle_call(:stop, _from, %{pid: pid}) do
    case :eldap.close(pid) do
      :ok -> {:reply, true, %{}}
      {:error, reason} -> {:reply, reason, %{}}
    end
  end

end
