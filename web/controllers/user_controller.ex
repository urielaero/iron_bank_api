defmodule IronBank.UserController do
  use IronBank.Web, :controller

  alias IronBank.User
  alias IronBankDoc.User, as: Doc

  @password_salt "moo7ukuS"
  @auth_required [:create, :update, :delete]
  plug Util.PlugAuthToken, [salt: @password_salt] when action in @auth_required
  
  @mailer_api Application.get_env(:iron_bank, :mailer_api) 
  @ldap_api Application.get_env(:iron_bank, :ldap_api)
  @token_api Application.get_env(:iron_bank, :token_api)
  @http_front Application.get_env(:iron_bank, :http_front)

  @cn_admin Application.get_env(:iron_bank, :cn_admin)
  @cn_password Application.get_env(:iron_bank, :cn_password)

  def swaggerdoc_index, do: Doc.index

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.json", users: users)
  end

  def swaggerdoc_create, do: Doc.create
  
  def create(conn, user_params) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        token = Phoenix.Token.sign(conn, "email", user.id)
        url = "#{@http_front}/#/register?token=#{token}"
        url_encode = URI.encode(url)
        spawn_link fn ->
          @mailer_api.send_url_password(user.email, url_encode, token)
        end

        conn
        |> put_status(:created)
        |> render("show.json", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(IronBank.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def swaggerdoc_show, do: Doc.show

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.json", user: user)
  end

  def swaggerdoc_update, do: Doc.update

  #def update(conn, %{"id" => id, "password" => password, "new_password" => new_password}) do
  #  IO.puts "YOLO!!!"
    
  #end

  def update(conn, %{"id" => id} = user_params) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        render(conn, "show.json", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(IronBank.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def swaggerdoc_set_password, do: Doc.set_password

  def set_password(conn, %{"token" => token, "password" => password}) do
    case Phoenix.Token.verify(conn, "email", token) do
      {:ok, id} -> 
        user = Repo.get!(User, id)
        case do_create_ldap(user, password) do
          :ok -> render(conn, "show.json", user: user)
          {:error, msg} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(IronBank.ChangesetView, "error.json", changeset: msg)
        end
      {:error, msg} -> 
        conn
        |> put_status(:unprocessable_entity)
        |> render(IronBank.ChangesetView, "error.json", changeset: msg)
    end
  end

  defp do_create_ldap(user, password) do
    ldap = User.format_ldap(user)
    ch_password = to_char_list(password)
    case @ldap_api.create(ldap.cn, ldap.attributes) do
      :ok -> @ldap_api.set_password(ldap.cn, ch_password)
      {:error, :entryAlreadyExists} -> @ldap_api.set_password(ldap.cn, ch_password)
      {:error, msg} -> {:error, msg}
    end
    
  end

  def swaggerdoc_login, do: Doc.login

  def login(conn, %{"code" => id, "password" => password}) do
    user = Repo.get!(User, id)
    ldap = User.format_ldap(user)
    ch_password = to_char_list(password)
    case @ldap_api.verify(ldap.cn, ch_password) do
      true -> 
        token = @token_api.sign(conn, @password_salt, user.id) 
        render(conn, "user_login.json", user: user, token: token)
      false -> 
        conn
        |> put_status(:forbidden)
        |> render(IronBank.ChangesetView, "error.json", changeset: "password invalid")
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    send_resp(conn, :no_content, "")
  end
end
