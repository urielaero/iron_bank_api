defmodule Util.Mailer do
  @config domain: Application.get_env(:iron_bank, :mailgun_domain),
          key: Application.get_env(:iron_bank, :mailgun_key),
          httpc_opts: [connect_timeout: 4000, timeout: 5000]

  use Mailgun.Client, @config

  @from "iron_bank@braavos.com"

  def do_send(email, html) do
    IO.inspect @config
    send_email to: email,
               from: @from,
               subject: "test",
               html: html
  end

  def send_url_password(email, url, _token) do
    html = "<h1>Bienvenido al Banco de hierro, para completar el proceso por favor haz click en el siguiente enlace <a href='#{url}'>#{url}</a></h1>"

    do_send(email, html)
  end

  def send_notify(email, action, msg) do
    html ="<p> Se a realizado la siguente accion: <br/> #{msg} <br/> para mas información consulte su cuenta </p>"
    send_email to: email,
               from: @from,
               subject: action,
               html: html
  end

  def inMemory?(), do: false
end

defmodule Util.Mailer.InMemory do
  
  def start_link do
    Agent.start_link(fn -> 
      %{}
    end, name: __MODULE__)
  end

  def send_url_password(email, _url, token) do
    Agent.update(__MODULE__, &(Dict.put(&1, email, token)))
  end

  def get_inbox(email) do
    Agent.get_and_update(__MODULE__, fn inboxs -> 
      Dict.pop(inboxs, email)
    end)
  end

  def get_notify(email, action) do
    Agent.get(__MODULE__, fn inboxs -> 
      Dict.get(inboxs, "#{email}-#{action}")
    end)
  end

  def send_notify(email, action, msg) do
    Agent.update(__MODULE__, &(Dict.put(&1, "#{email}-#{action}", msg)))
  end

  def inMemory?(), do: true
end
