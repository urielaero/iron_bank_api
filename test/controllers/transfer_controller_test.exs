defmodule IronBank.TransferControllerTest do
  use IronBank.ConnCase

  alias IronBank.Transfer
  alias IronBank.UserControllerTest
  alias IronBank.User
  alias IronBank.Card
  @valid_attrs %{amount: 1.0, user_id: "54da3fde31f40c76004324c9", card_id: "54da3fde31f40c76004324c9"}
  @invalid_attrs %{}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    Util.PlugAuthTokenTest.start_link
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, transfer_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    transfer = Repo.insert! %Transfer{}
    conn = get conn, transfer_path(conn, :show, transfer)
    assert json_response(conn, 200)["data"] == %{"id" => transfer.id,
      "amount" => transfer.amount,
      "card" => %{}, 
      "user" => %{}}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, transfer_path(conn, :show, "54da3fde31f40c76004324c9")
    end
  end

  @tag :skip
  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, transfer_path(conn, :create), @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Transfer, @valid_attrs)
  end

  @tag :skip
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, transfer_path(conn, :create), @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag :skip
  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    transfer = Repo.insert! %Transfer{}
    conn = put conn, transfer_path(conn, :update, transfer), @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Transfer, @valid_attrs)
  end

  @tag :skip
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    transfer = Repo.insert! %Transfer{}
    conn = put conn, transfer_path(conn, :update, transfer), @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  @tag :skip
  test "deletes chosen resource", %{conn: conn} do
    transfer = Repo.insert! %Transfer{}
    conn = delete conn, transfer_path(conn, :delete, transfer)
    assert response(conn, 204)
    refute Repo.get(Transfer, transfer.id)
  end

  test "show data by month-year" do
    user_executive_token = UserControllerTest.insert_user(2, 'mypass')
    user = Repo.insert! %User{} 
    user_other = Repo.insert! %User{} 
    conn = get conn, transfer_path(conn, :month, [token: user_executive_token, user_id: user.id, month: "06", year: "2016"])
    assert json_response(conn, 200)["data"] == []
    card = Repo.insert! %Card{user_id: user.id}
    card_other = Repo.insert! %Card{user_id: user.id}
    {:ok, date} = Ecto.Date.cast "2016-06-01"
    date_time = Ecto.DateTime.from_date(date)
    Repo.insert! %Transfer{card_id: card.id, user_id: card.user_id, amount: 0.0, inserted_at: date_time}
    Repo.insert! %Transfer{card_id: card_other.id, user_id: card.user_id, amount: 10.0, inserted_at: date_time}
    Repo.insert! %Transfer{card_id: card.id, user_id: user_other.id, amount: 0.0, inserted_at: date_time}
    conn = get conn, transfer_path(conn, :month, [token: user_executive_token, user_id: user.id, month: "06", year: "2016"])
    res = json_response(conn, 200)["data"]
    assert length(res) == 2

    # filter by card_id
    conn = get conn, transfer_path(conn, :month, [token: user_executive_token, user_id: user.id, card_id: card_other.id, month: "06", year: "2016"])
    res = json_response(conn, 200)["data"]
    assert length(res) == 1
    assert hd(res)["card"]["id"] == card_other.id
  end
end
