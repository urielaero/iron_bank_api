defmodule IronBank.PageController do
  use IronBank.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def doc(conn, _params), do: text conn, File.read! "swagger/api.json"
end
