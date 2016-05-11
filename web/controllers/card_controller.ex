defmodule IronBank.CardController do
  use IronBank.Web, :controller

  alias IronBank.Card
  alias IronBankDoc.Card, as: Doc
  alias IronBank.User
  alias IronBank.Transfer
  alias Util.PlugAuthToken

  @password_salt "moo7ukuS"
  @auth_required [:create, :update, :delete]
  plug PlugAuthToken, [salt: @password_salt] when action in @auth_required

  @mailer_api Application.get_env(:iron_bank, :mailer_api) 

  def swaggerdoc_index, do: Doc.index

  def index(conn, _params) do
    cards = Repo.all(Card)
    render(conn, "index.json", cards: cards)
  end

  def swaggerdoc_create, do: Doc.create

  def create(conn, card_params) do
    changeset = Card.changeset(%Card{}, card_params)

    case Repo.insert(changeset) do
      {:ok, card} ->
        transfer(card_params["user_id"], card, 0.0)
        conn
        |> put_status(:created)
        |> render("show.json", card: card)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(IronBank.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def swaggerdoc_show, do: Doc.show

  def show(conn, %{"id" => id}) do
    card = Repo.get!(Card, id)
    render(conn, "show.json", card: card)
  end

  defp update_from_client(conn, %{"amount" => amount, "from_card_id" => from_card_id} = card_params, user_deposit) when amount > 0 do
    from_card = Repo.get!(Card, from_card_id)
    if from_card.amount >= amount || user_deposit == "interbancaria" do
      update(conn, card_params, user_deposit)
    else
      PlugAuthToken.unauthorized(conn)
    end
  end

  def swaggerdoc_update, do: Doc.update

  def update(conn, card_params) do
    user_id = PlugAuthToken.get_data(conn)
    user = Repo.get!(User, user_id)
    if (user.type != :client), do: update(conn, card_params, user),
    else: update_from_client(conn, card_params, user)
    #PlugAuthToken.unauthorized(conn)
  end

  def update(conn, %{"id" => id} = card_params, _user_auth) do
    card = Repo.get!(Card, id)
    {card_params, amount} = amount(card, card_params)
    changeset = Card.changeset(card, card_params)
    case Repo.update(changeset) do
      {:ok, card} ->
        if amount != nil do
          transfer(card.user_id, card, amount)
          notify_amount(amount, card)
        end
        render(conn, "show.json", card: card)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(IronBank.ChangesetView, "error.json", changeset: changeset)
    end
  end

  defp amount(card, %{"amount" => amount} = params) when is_number(amount) do
    {Dict.put(params, "amount", card.amount + amount), amount}
  end

  defp amount(card, %{"amount" => amount} = params) when is_binary(amount) do
    {val, _} = Integer.parse(amount)
    {Dict.put(params, "amount", card.amount + val), val}
  end

  defp amount(_card, params) do 
    {params, nil}
  end

  defp notify_amount(nil, _), do: :ok
  defp notify_amount(amount, card) when amount > 0 do 
    nofity_transaction("Deposito", card, amount)
  end

  defp notify_amount(amount, card) when amount < 0 do 
    nofity_transaction("Retiro", card, amount)
  end

  defp nofity_transaction(action, card, amount) do
    if @mailer_api.inMemory? do
      do_nofity_transaction(action, card, amount)
    else
      spawn_link fn -> 
        do_nofity_transaction(action, card, amount)
      end
    end
    :ok
  end

  defp do_nofity_transaction(action, card, amount) do
    user = Repo.get!(User, card.user_id)
    abs_amount = abs(amount)
    info = "#{action} con valor de #{abs_amount} correcto, nuevo saldo: #{card.amount}"
    @mailer_api.send_notify(user.email, action, info)
  end

  def delete(conn, %{"id" => id}) do
    card = Repo.get!(Card, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(card)

    send_resp(conn, :no_content, "")
  end

  defp transfer(user_id, card, amount) do
    params = %{user_id: user_id, card_id: card.id, amount: amount, amount_now: card.amount} 
    changeset = Transfer.changeset(%Transfer{}, params)
    case Repo.insert(changeset) do
      {:ok, card} -> card
      {:error, changeset} -> changeset
    end
  end

  def bank_transfer(conn, %{"amount" => amount, "origin_account" => origin, "destination_account" => destination, "bank_origin" => bank} = params) do
    card = Repo.get!(Card, destination)
    user = Repo.get!(User, card.user_id)
    params = params
              |> Dict.put("id", card.id)
              |> Dict.put("from_card_id", card.id)

    info = "Se esta procesando una transferencia interbancaria con valor de #{amount} de la cuenta #{origin} del banco #{bank} a tu cuenta #{destination}"
    @mailer_api.send_notify(user.email, "Transferencia interbancaria en proceso", info)
    update_from_client(conn, params, "interbancaria")
  end
end
