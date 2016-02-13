defmodule Util.PlugAuthToken do
  
  import Plug.Conn, only: [halt: 1, put_resp_content_type: 2, send_resp: 3, assign: 3] 

  alias Plug.Conn

  @token_api Application.get_env(:iron_bank, :token_api)

  def init(options), do: options

  def call(%Conn{params: params} = conn, options) do
    do_call conn, params, options
  end


  defp do_call(conn, %{"token" => token}, opts), do: authenticate(conn, token, opts)
  defp do_call(conn, _params, _opts), do: unauthorized(conn)

  defp authenticate(conn, token, opts) do
    salt = Keyword.get(opts, :salt, "token")
    max_age = Keyword.get(opts, :max_age, 1209600)
    case @token_api.verify(conn, salt, token, max_age: max_age) do
      {:ok, user_id} -> assign(conn, :token_data, user_id)
      _ -> unauthorized(conn)
    end
  end

  def unauthorized(conn) do
    conn
      |> put_resp_content_type("application/json")
      |> send_resp(401, "{\"error\": \"unauthorized\"}")
      |> halt
  end

  def get_data(conn), do: conn.assigns[:token_data]
end
