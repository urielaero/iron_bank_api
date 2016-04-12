defmodule IronBank.TransferController do
  use IronBank.Web, :controller

  alias IronBank.Transfer
  alias Util.PlugAuthToken

  @password_salt "moo7ukuS"
  @auth_required [:create, :update, :delete]
  plug PlugAuthToken, [salt: @password_salt] when action in @auth_required

  def index(conn, _params) do
    transfers = Repo.all(Transfer)
    render(conn, "index.json", transfers: transfers)
  end

  def create(conn, transfer_params) do
    changeset = Transfer.changeset(%Transfer{}, transfer_params)

    case Repo.insert(changeset) do
      {:ok, transfer} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", transfer_path(conn, :show, transfer))
        |> render("show.json", transfer: transfer)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(IronBank.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    transfer = Repo.get!(Transfer, id)
    render(conn, "show.json", transfer: transfer)
  end

  def update(conn, %{"id" => id} = transfer_params) do
    transfer = Repo.get!(Transfer, id)
    changeset = Transfer.changeset(transfer, transfer_params)

    case Repo.update(changeset) do
      {:ok, transfer} ->
        render(conn, "show.json", transfer: transfer)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(IronBank.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    transfer = Repo.get!(Transfer, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(transfer)

    send_resp(conn, :no_content, "")
  end

  def month(conn, %{"user_id" => user_id, "month" => month, "year" => year} = transfer_params) do
    card_id = transfer_params["card_id"] #optional
    transfers = Transfer 
                |> Transfer.filter_by_user_id(user_id)
                |> Transfer.filter_by_card_id(card_id)
                |> Transfer.filter_by_date(month, year)
                |> Transfer.preload
                |> Repo.all

    render(conn, "index.json", transfers: transfers)
  end
end
