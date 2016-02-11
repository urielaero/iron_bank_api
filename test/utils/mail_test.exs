defmodule Util.MailerTest do
  use ExUnit.Case

  alias Util.Mailer

  @moduletag :mailer

  test "should send email" do
    {:ok, res} = Mailer.send_url_password("aero.uriel@gmail.com", "http://google.com")
    assert res =~ "id"
  end



end
