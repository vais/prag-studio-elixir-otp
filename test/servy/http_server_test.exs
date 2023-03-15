defmodule Servy.HttpServerTest do
  use ExUnit.Case

  alias Servy.{HttpServer, HttpClient}

  test "the server" do
    spawn(HttpServer, :start, [4000])

    request = """
    GET /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = HttpClient.send(request)

    assert response =~ "All the Bears!"
  end
end
