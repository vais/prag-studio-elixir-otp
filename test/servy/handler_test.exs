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

  def without_file(file, function) do
    File.rename!(file, "#{file}.bak")

    try do
      function.()
    after
      File.rename!("#{file}.bak", file)
    end
  end

  test "route /about" do
    conv = %Handler{
      method: "GET",
      path: "/about"
    }

    file = Path.expand("../../pages/about.html", __DIR__)

    new_conv = Handler.route(conv)
    assert new_conv.status == 200
    assert new_conv.resp_body == File.read!(file)

    new_conv = without_file(file, fn -> Handler.route(conv) end)
    assert new_conv.status == 404
    assert new_conv.resp_body == "File not found"
  end

  test "route /bears/new" do
    conv = %Handler{
      method: "GET",
      path: "/bears/new"
    }

    file = Path.expand("../../pages/form.html", __DIR__)

    new_conv = Handler.route(conv)
    assert new_conv.status == 200
    assert new_conv.resp_body == File.read!(file)

    new_conv = without_file(file, fn -> Handler.route(conv) end)
    assert new_conv.status == 404
    assert new_conv.resp_body == "File not found"
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
