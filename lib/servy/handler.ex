defmodule Servy.Handler do
  defstruct method: nil, path: nil, status: nil, resp_body: nil

  require Logger

  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> route
    |> emojify
    |> track
    |> format_response
  end

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    %__MODULE__{method: method, path: path}
  end

  def emojify(%{method: "GET", status: 200} = conv) do
    %{conv | resp_body: "👍 #{conv.resp_body} 🔥"}
  end

  def emojify(conv), do: conv

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%{path: path} = conv) do
    regex = ~r"^/(?<resource>\w+)\?id=(?<id>\d+)$"
    captures = Regex.named_captures(regex, path)
    rewrite_path(conv, captures)
  end

  defp rewrite_path(conv, _captures = %{"resource" => resource, "id" => id}) do
    %{conv | path: "/#{resource}/#{id}"}
  end

  defp rewrite_path(conv, _captures = nil), do: conv

  defp handle_file({:ok, content}, conv) do
    %{conv | status: 200, resp_body: content}
  end

  defp handle_file({:error, :enoent}, conv) do
    %{conv | status: 404, resp_body: "File not found"}
  end

  def route(%{method: "GET", path: "/about"} = conv) do
    "../../pages/about.html"
    |> Path.expand(__DIR__)
    |> File.read()
    |> handle_file(conv)
  end

  def route(%{method: "GET", path: "/bears/new"} = conv) do
    "../../pages/form.html"
    |> Path.expand(__DIR__)
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

  def track(%{status: 404} = conv) do
    conv
    |> Map.take([:method, :path, :status])
    |> Map.values()
    |> Enum.join(" ")
    |> Logger.error()

    conv
  end

  def track(conv), do: conv

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
