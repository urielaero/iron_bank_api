defmodule IronBank.CardControllerTest do
  use IronBank.ConnCase

  alias IronBank.Card
  alias IronBank.UserControllerTest
  alias IronBank.User
  alias IronBank.Transfer
  alias Util.Mailer.InMemory, as: Mailer
  @valid_attrs %{active: true, name: :nomina, type: :credit}
  @invalid_attrs %{}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    Mailer.start_link
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
      "amount" => card.amount,
      "user_id" => card.user_id,
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

  test "add card to user" do
    user = Repo.insert!(%User{})
    user_executive_token = UserControllerTest.insert_user(2, 'mypass')
    valid = @valid_attrs
    valid = Dict.put(valid, :token, user_executive_token)
          |> Dict.put(:user_id, user.id)
    conn = post conn, card_path(conn, :create), valid
    assert json_response(conn, 201)["data"]["user_id"] == user.id
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



  test "transfer from a client to b amount" do
    user_token = UserControllerTest.insert_user(0, 'mypass')
    user_a = Repo.insert! %User{email: "a@host.com"}
    card_a = Repo.insert! %Card{user_id: user_a.id, amount: 13.0}

    valid = Dict.put(@valid_attrs, :token, user_token)
            |> Dict.put(:amount, 12)
            |> Dict.put(:from_card_id, card_a.id)

    user_b = Repo.insert! %User{email: "b@host.com"}
    card = Repo.insert! %Card{user_id: user_b.id}
    conn = put conn, card_path(conn, :update, card), valid
    assert json_response(conn, 200)["data"]["amount"] === 12.0
  end

  test "update amount if UserTypeEnum > 0" do
    user_executive_token = UserControllerTest.insert_user(2, 'mypass')
    valid = Dict.put(@valid_attrs, :token, user_executive_token)
            |> Dict.put(:amount, 12)
    user = Repo.insert! %User{email: "uno@host.com"}
    card = Repo.insert! %Card{user_id: user.id}
    conn = put conn, card_path(conn, :update, card), valid
    assert json_response(conn, 200)["data"]["amount"] === 12.0

    #notify 
    add = Mailer.get_notify("uno@host.com", "Deposito")
    assert add =~ "Deposito con valor de 12"
  end

  test "if amount is positive, increment amount" do
    user_executive_token = UserControllerTest.insert_user(2, 'mypass')
    valid = Dict.put(@valid_attrs, :token, user_executive_token)
            |> Dict.put(:amount, "12")
    user = Repo.insert! %User{email: "dos@host.com"}
    card = Repo.insert! %Card{amount: 50.0, user_id: user.id}
    conn = put conn, card_path(conn, :update, card), valid
    assert json_response(conn, 200)["data"]["amount"] === 62.0
    #notify 
    add = Mailer.get_notify("dos@host.com", "Deposito")
    assert add =~ "62"
  end

  test "amount transfer from other banks" do
    user_executive_token = UserControllerTest.insert_user(2, 'mypass')
    valid = @valid_attrs |> Dict.put(:amount, "12")
    user = Repo.insert! %User{email: "dos@host.com"}
    card = Repo.insert! %Card{amount: 50.0, user_id: user.id, type: 0, name: 0}

    params = %{"amount" => "12", "origin_account" => "some string field", "destination_account" => card.id, "bank_origin" => "some bank"}
    conn = post conn, card_path(conn, :bank_transfer), params
    assert json_response(conn, 200)["data"]["amount"] === 62.0

    add = Mailer.get_notify("dos@host.com", "Deposito")
    assert add =~ "62"

  end

  test "if amount is negative, decrement amount" do
    user_executive_token = UserControllerTest.insert_user(2, 'mypass')
    valid = Dict.put(@valid_attrs, :token, user_executive_token)
            |> Dict.put(:amount, -12)
    user = Repo.insert! %User{email: "tres@host.com"}
    card = Repo.insert! %Card{amount: 50.0, user_id: user.id}
    conn = put conn, card_path(conn, :update, card), valid
    assert json_response(conn, 200)["data"]["amount"] === 38.0
    #notify 
    add = Mailer.get_notify("tres@host.com", "Retiro")
    add =~ "38.0"
  end

  test "if create card, create a transfer with value of 0" do
    user_executive_token = UserControllerTest.insert_user(2, 'mypass')
    user_client = Repo.insert! %User{type: 0}
    valid = @valid_attrs
            |> Dict.put(:token, user_executive_token)
            |> Dict.put(:user_id, user_client.id)
    conn = post conn, card_path(conn, :create), valid
    card = json_response(conn, 201)["data"]
    assert card["id"]
    assert Repo.get_by(Transfer, user_id: user_client.id, card_id: card["id"])
  end

  test "when amount change, create a transfer with that transfer" do
    user_executive_token = UserControllerTest.insert_user(2, 'mypass')
    user_client = Repo.insert! %User{type: 0}
    valid = Dict.put(@valid_attrs, :token, user_executive_token)
            |> Dict.put(:amount, 12)
    card = Repo.insert! %Card{amount: 0.0, user_id: user_client.id}
    conn = put conn, card_path(conn, :update, card), valid
    res = json_response(conn, 200)["data"]
    assert res["amount"] == 12
    assert Repo.get_by(Transfer, user_id: user_client.id, card_id: res["id"], amount: 12)

  end
end
