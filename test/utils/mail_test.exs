defmodule Util.MailerTest do
  use ExUnit.Case

  alias Util.Mailer

  @moduletag :mailer

  test "should send email" do
    {:ok, res} = Mailer.send_url_password("aero.uriel@gmail.com", "http://google.com", "dummy")
    assert res =~ "id"
  end

  test "should send email with action and msg" do
    {:ok, res} = Mailer.send_notify("aero.uriel@gmail.com", "Deposito y/o retiro", " Deposito de 5 a tu numero de cuenta")
    assert res =~ "id"
  end

end
