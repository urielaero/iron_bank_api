defmodule IronBank.CardControllerTest do
  use IronBank.ConnCase

  alias IronBank.Card
  alias IronBank.UserControllerTest
  @valid_attrs %{active: true, name: :nomina, type: :credit}
  @invalid_attrs %{}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    Util.PlugAuthTokenTest.start_link
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, card_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    card = Repo.insert! %Card{type: 0}
    conn = get conn, card_path(conn, :show, card)
    assert json_response(conn, 200)["data"] == %{"id" => card.id,
      "type" => "debit",
      "card_number" => card.id,
      "name" => card.name,
      "active" => card.active}


  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, card_path(conn, :show, "54da3fde31f40c76004324c9")
    end
  end
  
  test "creates and renders resource when data is valid", %{conn: conn} do
    user_executive_token = UserControllerTest.insert_user(2, 'mypass')
    valid = @valid_attrs
    valid = Dict.put(valid, :token, user_executive_token)
    conn = post conn, card_path(conn, :create), valid
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Card, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    user_executive_token = UserControllerTest.insert_user(2, 'mypass')
    invalid = @invalid_attrs
    invalid = Dict.put(invalid, :token, user_executive_token)
    conn = post conn, card_path(conn, :create), invalid
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    user_executive_token = UserControllerTest.insert_user(2, 'mypass')
    valid = @valid_attrs
    valid = Dict.put(valid, :token, user_executive_token)
    card = Repo.insert! %Card{}
    conn = put conn, card_path(conn, :update, card), valid
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Card, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user_executive_token = UserControllerTest.insert_user(2, 'mypass')
    invalid = @invalid_attrs
    invalid = Dict.put(invalid, :token, user_executive_token)
    card = Repo.insert! %Card{}
    conn = put conn, card_path(conn, :update, card), invalid
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    user_executive_token = UserControllerTest.insert_user(2, 'mypass')
    card = Repo.insert! %Card{}
    conn = delete conn, card_path(conn, :delete, card), token: user_executive_token
    assert response(conn, 204)
    refute Repo.get(Card, card.id)
  end
end
