defmodule IronBank.PageController do
  use IronBank.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
