defmodule Servy.ParserTest do
  use ExUnit.Case

  alias Servy.Parser
  alias Servy.Handler

  test "parse" do
    request = """
    GET /wildthings HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    conv = %Handler{
      method: "GET",
      path: "/wildthings"
    }

    assert Parser.parse(request) == conv
  end
end
