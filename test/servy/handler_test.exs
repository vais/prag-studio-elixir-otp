defmodule Servy.HandlerTest do
  use ExUnit.Case

  alias Servy.Conv
  alias Servy.Handler

  test "route /wildthings" do
    conv = %Conv{
      method: "GET",
      path: "/wildthings"
    }

    new_conv = %Conv{
      method: "GET",
      path: "/wildthings",
      status: 200,
      resp_body: "Bears, Lions, Tigers"
    }

    assert Handler.route(conv) == new_conv
  end

  test "route /bears" do
    conv = %Conv{
      method: "GET",
      path: "/bears"
    }

    new_conv = %Conv{
      method: "GET",
      path: "/bears",
      status: 200,
      resp_body: "Bears"
    }

    assert Handler.route(conv) == new_conv
  end

  test "route /bears/1" do
    conv = %Conv{
      method: "GET",
      path: "/bears/1"
    }

    new_conv = %Conv{
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
    conv = %Conv{
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
    conv = %Conv{
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
    conv = %Conv{
      method: "GET",
      path: "/bigfoot"
    }

    new_conv = %Conv{
      method: "GET",
      path: "/bigfoot",
      status: 404,
      resp_body: "Can't GET /bigfoot here"
    }

    assert Handler.route(conv) == new_conv
  end

  test "format_response 200" do
    conv = %Conv{
      method: "GET",
      path: "/wildthings",
      status: 200,
      resp_body: "Bears, Lions, Tigers"
    }

    response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 20

    Bears, Lions, Tigers
    """

    assert Handler.format_response(conv) == response
  end

  test "format_response 404" do
    conv = %Conv{
      method: "GET",
      path: "/bigfoot",
      status: 404,
      resp_body: "Can't GET /bigfoot here"
    }

    response = """
    HTTP/1.1 404 Not Found
    Content-Type: text/html
    Content-Length: 23

    Can't GET /bigfoot here
    """

    assert Handler.format_response(conv) == response
  end

  test "GET /wildthings" do
    request = """
    GET /wildthings HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 30

    👍 Bears, Lions, Tigers 🔥
    """

    assert Handler.handle(request) == response
  end

  test "GET /wildlife" do
    request = """
    GET /wildlife HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 30

    👍 Bears, Lions, Tigers 🔥
    """

    assert Handler.handle(request) == response
  end

  test "GET /bigfoot" do
    request = """
    GET /bigfoot HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    response = """
    HTTP/1.1 404 Not Found
    Content-Type: text/html
    Content-Length: 23

    Can't GET /bigfoot here
    """

    io =
      ExUnit.CaptureLog.capture_log(fn ->
        assert Handler.handle(request) == response
      end)

    assert io =~ "GET /bigfoot 404\n"
  end

  test "POST /bears" do
    request = """
    POST /bears HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*
    Content-Type: application/x-www-form-urlencoded
    Content-Length: 21

    name=Baloo&type=Brown
    """

    response = """
    HTTP/1.1 201 Created
    Content-Type: text/html
    Content-Length: 33

    Created a Brown bear named Baloo!
    """

    assert Handler.handle(request) == response
  end

  test "POST /bears Bad Request" do
    request = """
    POST /bears HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*
    Content-Type: multipart/form-data
    Content-Length: 21

    name=Baloo&type=Brown
    """

    response = """
    HTTP/1.1 400 Bad Request
    Content-Type: text/html
    Content-Length: 33

    name and type are required fields
    """

    assert Handler.handle(request) == response
  end
end
