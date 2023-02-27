defmodule Servy.HandlerTest do
  use ExUnit.Case

  alias Servy.Handler

  test "parse" do
    request = """
    GET /wildthings HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    conv = %{
      method: "GET",
      path: "/wildthings",
      status: 200,
      resp_body: ""
    }

    assert Handler.parse(request) == conv
  end

  test "route /wildthings" do
    conv = %{
      method: "GET",
      path: "/wildthings",
      resp_body: ""
    }

    new_conv = %{
      method: "GET",
      path: "/wildthings",
      resp_body: "Bears, Lions, Tigers"
    }

    assert Handler.route(conv) == new_conv
  end

  test "route /bears" do
    conv = %{
      method: "GET",
      path: "/bears",
      resp_body: ""
    }

    new_conv = %{
      method: "GET",
      path: "/bears",
      resp_body: "Bears"
    }

    assert Handler.route(conv) == new_conv
  end

  test "route 404" do
    conv = %{
      method: "GET",
      path: "/bigfoot",
      status: 200,
      resp_body: ""
    }

    new_conv = %{
      method: "GET",
      path: "/bigfoot",
      status: 404,
      resp_body: "Can't GET /bigfoot here"
    }

    assert Handler.route(conv) == new_conv
  end

  test "format_response 200" do
    conv = %{
      method: "GET",
      path: "/wildthings",
      status: 200,
      resp_body: "Bears, Lions, Tigers"
    }

    response = """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 20\r
    \r
    Bears, Lions, Tigers
    """

    assert Handler.format_response(conv) == response
  end

  test "format_response 404" do
    conv = %{
      method: "GET",
      path: "/bigfoot",
      status: 404,
      resp_body: "Can't GET /bigfoot here"
    }

    response = """
    HTTP/1.1 404 Not Found\r
    Content-Type: text/html\r
    Content-Length: 23\r
    \r
    Can't GET /bigfoot here
    """

    assert Handler.format_response(conv) == response
  end

  test "GET /wildthings" do
    request = """
    GET /wildthings HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 20\r
    \r
    Bears, Lions, Tigers
    """

    assert Handler.handle(request) == response
  end

  test "GET /bigfoot" do
    request = """
    GET /bigfoot HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = """
    HTTP/1.1 404 Not Found\r
    Content-Type: text/html\r
    Content-Length: 23\r
    \r
    Can't GET /bigfoot here
    """

    assert Handler.handle(request) == response
  end
end
