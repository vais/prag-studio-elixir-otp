defmodule Servy.ParserTest do
  use ExUnit.Case

  alias Servy.Parser
  alias Servy.Conv

  test "parse a GET request" do
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

  test "parse a POST request" do
    request = """
    POST /bears HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*
    Content-Type: application/x-www-form-urlencoded
    Content-Length: 21

    name=Baloo&type=Brown
    """

    conv = %Conv{
      method: "POST",
      path: "/bears",
      params: %{"name" => "Baloo", "type" => "Brown"}
    }

    assert Parser.parse(request) == conv
  end
end
