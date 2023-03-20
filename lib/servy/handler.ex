defmodule Servy.Handler do
  alias Servy.Parser
  alias Servy.Plugins
  alias Servy.Conv
  alias Servy.BearController
  alias Servy.Api
  alias Servy.VideoCam
  alias Servy.Tracker

  @pages_path Path.expand("../../pages", __DIR__)

  def handle(request) do
    request
    |> Parser.parse()
    |> Plugins.rewrite_path()
    |> route
    |> Plugins.track()
    |> Plugins.content_length()
    |> format_response
  end

  defp handle_file({:ok, content}, %Conv{} = conv) do
    %{conv | status: 200, resp_body: content}
  end

  defp handle_file({:error, :enoent}, %Conv{} = conv) do
    %{conv | status: 404, resp_body: "File not found"}
  end

  defp markdown_to_html(%Conv{status: 200, resp_body: markdown} = conv) do
    %{conv | status: 200, resp_body: Earmark.as_html!(markdown, compact_output: true)}
  end

  defp markdown_to_html(%Conv{} = conv), do: conv

  def route(%Conv{method: "GET", path: "/sensors"} = conv) do
    smokey = Task.async(Tracker, :get_location, ["smokey"])

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(VideoCam, :get_snapshot, [&1]))
      |> Enum.map(&Task.await/1)

    body = %{
      snapshots: snapshots,
      smokey: Task.await(smokey)
    }

    %{conv | status: 200, resp_body: Poison.encode!(body)}
  end

  def route(%Conv{method: "GET", path: "/kaboom"} = _conv) do
    raise "Kaboom!"
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    time |> String.to_integer() |> Process.sleep()
    %{conv | status: 200, resp_body: "I'm awake now!"}
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/pages/" <> name} = conv) do
    @pages_path
    |> Path.join("#{name}.md")
    |> File.read()
    |> handle_file(conv)
    |> markdown_to_html()
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Api.BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.delete(conv, params)
  end

  def route(%Conv{method: method, path: path} = conv) do
    %{conv | status: 404, resp_body: "Can't #{method} #{path} here"}
  end

  defp format_response_headers(%Conv{} = conv) do
    conv.resp_headers
    |> Enum.map(fn {key, value} -> "#{key}: #{value}" end)
    |> Enum.sort(fn a, b -> b < a end)
    |> Enum.join("\r\n")
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}\r
    \r
    #{conv.resp_body}
    """
  end
end
