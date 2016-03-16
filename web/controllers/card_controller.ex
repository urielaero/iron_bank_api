defmodule IronBank.CardController do
  use IronBank.Web, :controller

  alias IronBank.Card
  alias IronBankDoc.Card, as: Doc
  alias IronBank.User
  alias Util.PlugAuthToken

  @password_salt "moo7ukuS"
  @auth_required [:create, :update, :delete]
  plug PlugAuthToken, [salt: @password_salt] when action in @auth_required

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

  def swaggerdoc_update, do: Doc.update

  def update(conn, card_params) do
    user_id = PlugAuthToken.get_data(conn)
    user = Repo.get!(User, user_id)
    if (user.type != :client), do: update(conn, card_params, user),
    else: PlugAuthToken.unauthorized(conn)
  end

  def update(conn, %{"id" => id} = card_params, _user_auth) do
    card = Repo.get!(Card, id)
    
    card_params = amount(card, card_params)
    changeset = Card.changeset(card, card_params)
    case Repo.update(changeset) do
      {:ok, card} ->
        render(conn, "show.json", card: card)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(IronBank.ChangesetView, "error.json", changeset: changeset)
    end
  end

  defp amount(card, %{"amount" => amount} = params) when is_number(amount) do
    Dict.put(params, "amount", card.amount + amount)
  end

  defp amount(card, %{"amount" => amount} = params) when is_binary(amount) do
    {val, _} = Integer.parse(amount)
    Dict.put(params, "amount", card.amount + val)
  end

  defp amount(_card, params) do 
    params
  end

  def delete(conn, %{"id" => id}) do
    card = Repo.get!(Card, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(card)

    send_resp(conn, :no_content, "")
  end
end
