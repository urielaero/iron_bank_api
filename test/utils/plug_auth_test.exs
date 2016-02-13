defmodule Util.PlugAuthTokenTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Util.PlugAuthToken
  @login_salt "Ca5aitweo3ooCe"
  @user_id "54da3fde31f40c76004324c9"

  @opts PlugAuthToken.init(salt: @login_salt)

  def config(opts) do 
    :ok
  end

  def verify(_endpoint, _salt, "token!", _opts) do
    {:ok, @user_id}
  end

  def verify(_endpoint, _salt, _token, _opts) do
    {:error, :bad_token}
  end

  test "return 401 if not token in request" do
    conn = conn(:get, "/hello")
    conn = PlugAuthToken.call(conn, @opts)
    assert conn.status == 401 
  end

  test "return 401 if bad token in request" do
    token = "bad"
    conn = conn(:get, "/hello", token: token)
    conn = PlugAuthToken.call(conn, @opts)
    assert conn.status == 401 
  end

  test "set :token_data from token" do
    token = "token!" 
    conn = conn(:get, "/hello", token: token)
    conn = PlugAuthToken.call(conn, @opts)
    assert conn.assigns[:token_data] == @user_id
    assert PlugAuthToken.get_data(conn) == @user_id
  end

end
