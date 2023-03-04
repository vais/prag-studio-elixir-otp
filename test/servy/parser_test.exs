defmodule Servy.ParserTest do
  use ExUnit.Case

  alias Servy.Parser
  alias Servy.Conv

  test "parse" do
    request = """
    GET /wildthings HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    conv = %Conv{
      method: "GET",
      path: "/wildthings"
    }

    assert Parser.parse(request) == conv
  end
end
