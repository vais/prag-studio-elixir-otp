defmodule Servy.HandlerTest do
  use ExUnit.Case

  alias Servy.Conv
  alias Servy.Handler
  alias Servy.HitCounterDiy, as: HitCounter

  setup do
    {:ok, hit_counter} = HitCounter.start_link(%{})
    on_exit(fn -> Process.exit(hit_counter, :shutdown) end)
  end

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
      resp_body: """
      <h1>All the Bears!</h1>
      <ul>
        <li>Brutus</li><li>Kenai</li><li>Scarface</li>
      </ul>
      """
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
      resp_body: """
      <h1>Show Bear</h1>
      <p>Is Teddy hibernating? <strong>true</strong></p>
      """
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

  test "route /pages/faq" do
    conv = %Conv{
      method: "GET",
      path: "/pages/faq"
    }

    new_conv = Handler.route(conv)
    assert new_conv.status == 200
    assert new_conv.resp_body =~ "<h1>Frequently Asked Questions</h1>"

    new_conv = Handler.route(%{conv | path: "/pages/nope"})
    assert new_conv.status == 404
    assert new_conv.resp_body == "File not found"
  end

  test "route /pages/ directory traversal vulnerability" do
    conv = %Conv{
      method: "GET",
      path: "/pages/../README"
    }

    new_conv = Handler.route(conv)
    assert new_conv.status == 200
    assert new_conv.resp_body =~ "<h1>Servy</h1>"
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
      resp_headers: %{"Content-Type" => "text/html", "Content-Length" => 20},
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
    conv = %Conv{
      method: "GET",
      path: "/bigfoot",
      status: 404,
      resp_headers: %{"Content-Type" => "text/html", "Content-Length" => 23},
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

    io =
      ExUnit.CaptureLog.capture_log(fn ->
        assert Handler.handle(request) == response
      end)

    assert io =~ "GET /bigfoot 404\n"
  end

  test "POST /bears" do
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

    response = """
    HTTP/1.1 201 Created\r
    Content-Type: text/html\r
    Content-Length: 33\r
    \r
    Created a Brown bear named Baloo!
    """

    assert Handler.handle(request) == response
  end

  test "POST /bears Bad Request" do
    request = """
    POST /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    Content-Type: multipart/form-data\r
    Content-Length: 21\r
    \r
    name=Baloo&type=Brown
    """

    response = """
    HTTP/1.1 400 Bad Request\r
    Content-Type: text/html\r
    Content-Length: 33\r
    \r
    name and type are required fields
    """

    assert Handler.handle(request) == response
  end

  test "DELETE /bears/1" do
    request = """
    DELETE /bears/1 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = """
    HTTP/1.1 403 Forbidden\r
    Content-Type: text/html\r
    Content-Length: 27\r
    \r
    Deleting bears is forbidden
    """

    assert Handler.handle(request) == response
  end

  defp remove_whitespace(string), do: String.replace(string, ~r"\s", "")

  test "GET /api/bears" do
    request = """
    GET /api/bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = Handler.handle(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Type: application/json\r
    Content-Length: 605\r
    \r
    [{"type":"Brown","name":"Teddy","id":1,"hibernating":true},
     {"type":"Black","name":"Smokey","id":2,"hibernating":false},
     {"type":"Brown","name":"Paddington","id":3,"hibernating":false},
     {"type":"Grizzly","name":"Scarface","id":4,"hibernating":true},
     {"type":"Polar","name":"Snow","id":5,"hibernating":false},
     {"type":"Grizzly","name":"Brutus","id":6,"hibernating":false},
     {"type":"Black","name":"Rosie","id":7,"hibernating":true},
     {"type":"Panda","name":"Roscoe","id":8,"hibernating":false},
     {"type":"Polar","name":"Iceman","id":9,"hibernating":true},
     {"type":"Grizzly","name":"Kenai","id":10,"hibernating":false}]
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  test "POST /api/bears" do
    request = """
    POST /api/bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    Content-Type: application/json\r
    Content-Length: 31\r
    \r
    {"name":"Baloo","type":"Brown"}
    """

    response = """
    HTTP/1.1 201 Created\r
    Content-Type: application/json\r
    Content-Length: 66\r
    \r
    {"status":"success","message":"Created a Brown bear named Baloo!"}
    """

    assert Handler.handle(request) == response
  end
end
