defmodule Servy.Handler do
  defstruct method: nil, path: nil, status: nil, resp_body: nil

  alias Servy.Parser
  alias Servy.Plugins

  @pages_path Path.expand("../../pages", __DIR__)

  def handle(request) do
    request
    |> Parser.parse()
    |> Plugins.rewrite_path()
    |> route
    |> Plugins.emojify()
    |> Plugins.track()
    |> format_response
  end

  defp handle_file({:ok, content}, conv) do
    %{conv | status: 200, resp_body: content}
  end

  defp handle_file({:error, :enoent}, conv) do
    %{conv | status: 404, resp_body: "File not found"}
  end

  def route(%{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%{method: "GET", path: "/bears"} = conv) do
    %{conv | status: 200, resp_body: "Bears"}
  end

  def route(%{method: "GET", path: "/bears/" <> id} = conv) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(%{method: method, path: path} = conv) do
    %{conv | status: 404, resp_body: "Can't #{method} #{path} here"}
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}\r
    Content-Type: text/html\r
    Content-Length: #{byte_size(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end

  defp status_reason(200), do: "OK"
  defp status_reason(201), do: "Created"
  defp status_reason(401), do: "Unauthorized"
  defp status_reason(403), do: "Forbidden"
  defp status_reason(404), do: "Not Found"
  defp status_reason(500), do: "Internal Server Error"
end
