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

    conv = %Handler{
      method: "GET",
      path: "/wildthings"
    }

    assert Handler.parse(request) == conv
  end

  test "rewrite_path" do
    conv = %Handler{
      path: "/wildlife"
    }

    new_conv = %Handler{
      path: "/wildthings"
    }

    assert new_conv == Handler.rewrite_path(conv)
  end

  test "rewrite_path with id" do
    conv = %Handler{
      path: "/bears?id=123"
    }

    new_conv = %Handler{
      path: "/bears/123"
    }

    assert new_conv == Handler.rewrite_path(conv)
  end

  test "route /wildthings" do
    conv = %Handler{
      method: "GET",
      path: "/wildthings"
    }

    new_conv = %Handler{
      method: "GET",
      path: "/wildthings",
      status: 200,
      resp_body: "Bears, Lions, Tigers"
    }

    assert Handler.route(conv) == new_conv
  end

  test "route /bears" do
    conv = %Handler{
      method: "GET",
      path: "/bears"
    }

    new_conv = %Handler{
      method: "GET",
      path: "/bears",
      status: 200,
      resp_body: "Bears"
    }

    assert Handler.route(conv) == new_conv
  end

  test "route /bears/1" do
    conv = %Handler{
      method: "GET",
      path: "/bears/1"
    }

    new_conv = %Handler{
      method: "GET",
      path: "/bears/1",
      status: 200,
      resp_body: "Bear 1"
    }

    assert Handler.route(conv) == new_conv
  end

  test "route 404" do
    conv = %Handler{
      method: "GET",
      path: "/bigfoot"
    }

    new_conv = %Handler{
      method: "GET",
      path: "/bigfoot",
      status: 404,
      resp_body: "Can't GET /bigfoot here"
    }

    assert Handler.route(conv) == new_conv
  end

  test "track 404" do
    io =
      ExUnit.CaptureLog.capture_log(fn ->
        Handler.track(%Handler{
          method: "GET",
          path: "/bigfoot",
          status: 404
        })
      end)

    assert io =~ "GET /bigfoot 404\n"
  end

  test "emojify" do
    conv = %Handler{method: "GET", status: 200, resp_body: "this should get emojified!"}
    new_conv = %{conv | resp_body: "👍 this should get emojified! 🔥"}
    assert new_conv == Handler.emojify(conv)

    conv = %Handler{method: "GET", status: 404, resp_body: "this should NOT get emojified"}
    assert conv == Handler.emojify(conv)
  end

  test "format_response 200" do
    conv = %Handler{
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
    conv = %Handler{
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
    Content-Length: 30\r
    \r
    👍 Bears, Lions, Tigers 🔥
    """

    assert Handler.handle(request) == response
  end

  test "GET /wildlife" do
    request = """
    GET /wildlife HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 30\r
    \r
    👍 Bears, Lions, Tigers 🔥
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

    io =
      ExUnit.CaptureLog.capture_log(fn ->
        assert Handler.handle(request) == response
      end)

    assert io =~ "GET /bigfoot 404\n"
  end
end
