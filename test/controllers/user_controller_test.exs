defmodule IronBank.UserControllerTest do
  use IronBank.ConnCase

  alias IronBank.User
  alias Util.Mailer.InMemory, as: Mailer
  alias Util.GenLdap.InMemory, as: GenLdap

  def insert_user(type, password) do
    user = Repo.insert! %User{name: "lol", last_name: "last lol", email: "other@gmail.com", type: type}
    ldap = User.format_ldap(user)
    GenLdap.set_password(ldap.cn, password)
    conn = post conn, user_path(conn, :login), code: user.id, password: password
    res = json_response(conn, 200)["data"]
    res["token"]
  end
  
  @valid_attrs %{type: :executive, active: true, address: "some content", email: "some@content.com", last_name: "some content", name: "some content", phone: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    Mailer.start_link
    GenLdap.start_link
    Util.PlugAuthTokenTest.start_link
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :show, user)
    assert json_response(conn, 200)["data"] == %{"id" => user.id,
      "name" => user.name,
      "last_name" => user.last_name,
      "email" => user.email,
      "address" => user.address,
      "phone" => user.phone,
      "code" => user.id,
      "type" => user.type,
      "cards" => [],
      "active" => user.active}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, user_path(conn, :show, "54da3fde31f40c76004324c9")
    end
  end

  test "should render cards" do
    user = Repo.insert! %User{}
    card1 = Repo.insert! %IronBank.Card{user_id: user.id}
    card2 = Repo.insert! %IronBank.Card{user_id: user.id}
    conn = get conn, user_path(conn, :show, user)
    res = json_response(conn, 200)["data"]
    [c1, c2] = res["cards"]
    assert c1["id"] == card1.id
    assert c2["id"] == card2.id
  end

  @tag :only
  test "creates and renders resource when data is valid", %{conn: conn} do
    user_executive_token = insert_user(2, 'mylol')
    valid = @valid_attrs
    valid = Dict.put(valid, :token, user_executive_token)
    conn = post conn, user_path(conn, :create), valid
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(User, @valid_attrs)

    inbox = Mailer.get_inbox(@valid_attrs[:email]) 
    assert inbox
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    user_executive_token = insert_user(2, 'mylol')
    valid = @invalid_attrs
    valid = Dict.put(valid, :token, user_executive_token)
    conn = post conn, user_path(conn, :create), valid 
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag :skip
  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, user), @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(User, @valid_attrs)
  end

  @tag :skip
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, user), @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    user_executive_token = insert_user(2, 'mylol')
    user = Repo.insert! %User{}
    conn = delete conn, user_path(conn, :delete, user), token: user_executive_token
    assert response(conn, 204)
    refute Repo.get(User, user.id)
  end


  test "should set password of user by url and token and verify login" do
    valid_to_create = @valid_attrs
    user_executive_token = insert_user(2, 'mylol')
    valid_to_create = Dict.put(valid_to_create, :token, user_executive_token)

    conn = post conn, user_path(conn, :create), valid_to_create 
    res = json_response(conn, 201)["data"]
    assert res["id"]
    token = Mailer.get_inbox(@valid_attrs[:email]) 
    password = "yolo#"
    conn = post conn, user_path(conn, :set_password), token: token, password: password
    res = json_response(conn, 200)["data"]
    assert res["id"]
    assert res["active"]

    conn = post conn, user_path(conn, :login), code: res["id"], password: password
    res = json_response(conn, 200)["data"]
    assert res["token"]

    conn = post conn, user_path(conn, :login), code: res["id"], password: "badpass"
    assert json_response(conn, 403)

    #send email with user info
    user_info = Mailer.get_notify(@valid_attrs[:email], "Registro correcto")
    assert user_info =~ "codigo de usuario"
  end

  @tag :skip
  test "should change password in update" do
    valid_to_create = @valid_attrs
    user_executive_token = insert_user(2, 'mylol')
    valid_to_create = Dict.put(valid_to_create, :token, user_executive_token)

    conn = post conn, user_path(conn, :create), valid_to_create 
    res = json_response(conn, 201)["data"]
    assert res["id"]
    token = Mailer.get_inbox(@valid_attrs[:email]) 
    password = "yolo#"
    conn = post conn, user_path(conn, :set_password), token: token, password: password
    assert json_response(conn, 200)["data"]

    conn = post conn, user_path(conn, :login), code: res["id"], password: password
    res = json_response(conn, 200)["data"]
    assert res["token"]
    
    #user = Repo.get!(User, res["id"])
    #new_password = "otherpass"
    #conn = put conn, user_path(conn, :update, user), token: res["token"], password: password, new_password: new_password
    #assert json_response(conn, 200)["data"]

    #conn = post conn, user_path(conn, :login), code: res["id"], password: new_password
    #res = json_response(conn, 200)["data"]
    #assert res["token"]
  end
end
