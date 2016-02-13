defmodule IronBank.UserControllerTest do
  use IronBank.ConnCase

  alias IronBank.User
  alias Util.Mailer.InMemory, as: Mailer
  alias Util.GenLdap.InMemory, as: GenLdap
  
  @valid_attrs %{type: :executive, active: true, address: "some content", email: "some@content.com", last_name: "some content", name: "some content", phone: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    Mailer.start_link
    GenLdap.start_link

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
      "active" => user.active}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, user_path(conn, :show, "54da3fde31f40c76004324c9")
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(User, @valid_attrs)

    inbox = Mailer.get_inbox(@valid_attrs[:email]) 
    assert inbox
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), @invalid_attrs
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
    user = Repo.insert! %User{}
    conn = delete conn, user_path(conn, :delete, user)
    assert response(conn, 204)
    refute Repo.get(User, user.id)
  end


  test "should set password of user by url and token and verify login" do
    conn = post conn, user_path(conn, :create), @valid_attrs
    res = json_response(conn, 201)["data"]
    assert res["id"]
    token = Mailer.get_inbox(@valid_attrs[:email]) 
    password = "yolo#"
    conn = post conn, user_path(conn, :set_password), token: token, password: password
    res = json_response(conn, 200)["data"]
    assert res["id"]
    assert res["active"]

    conn = post conn, user_path(conn, :login), code: res["id"], password: password
    assert json_response(conn, 200)["data"]

    conn = post conn, user_path(conn, :login), code: res["id"], password: "badpass"
    assert json_response(conn, 403)

  end
end
