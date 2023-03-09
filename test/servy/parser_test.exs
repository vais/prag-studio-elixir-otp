defmodule Servy.ParserTest do
  use ExUnit.Case
  doctest Servy.Parser

  alias Servy.Parser
  alias Servy.Conv

  test "parse a GET request" do
    request = """
    GET /wildthings HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    conv = %Conv{
      method: "GET",
      path: "/wildthings",
      headers: %{
        "Host" => "example.com",
        "User-Agent" => "ExampleBrowser/1.0",
        "Accept" => "*/*"
      }
    }

    assert Parser.parse(request) == conv
  end

  test "parse a POST request" do
    request = """
    POST /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    Content-Type: application/x-www-form-urlencoded\r
    Content-Length: 21\r
    \r
    name=Baloo&type=Brown
    """

    conv = %Conv{
      method: "POST",
      path: "/bears",
      headers: %{
        "Host" => "example.com",
        "User-Agent" => "ExampleBrowser/1.0",
        "Accept" => "*/*",
        "Content-Type" => "application/x-www-form-urlencoded",
        "Content-Length" => "21"
      },
      params: %{"name" => "Baloo", "type" => "Brown"}
    }

    assert Parser.parse(request) == conv
  end
end
