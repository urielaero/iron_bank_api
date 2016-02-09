defmodule IronBank.BankController do
  use IronBank.Web, :controller

  alias IronBank.Bank

  plug :scrub_params, "bank" when action in [:create, :update]

  def index(conn, _params) do
    banks = Repo.all(Bank)
    render(conn, "index.json", banks: banks)
  end

  def create(conn, %{"bank" => bank_params}) do
    changeset = Bank.changeset(%Bank{}, bank_params)

    case Repo.insert(changeset) do
      {:ok, bank} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", bank_path(conn, :show, bank))
        |> render("show.json", bank: bank)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(IronBank.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    bank = Repo.get!(Bank, id)
    render(conn, "show.json", bank: bank)
  end

  def update(conn, %{"id" => id, "bank" => bank_params}) do
    bank = Repo.get!(Bank, id)
    changeset = Bank.changeset(bank, bank_params)

    case Repo.update(changeset) do
      {:ok, bank} ->
        render(conn, "show.json", bank: bank)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(IronBank.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    bank = Repo.get!(Bank, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(bank)

    send_resp(conn, :no_content, "")
  end
end
