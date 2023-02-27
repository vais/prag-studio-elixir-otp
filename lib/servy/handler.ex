defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse
    |> route
    |> format_response
  end

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    %{
      method: method,
      path: path,
      status: 200,
      resp_body: ""
    }
  end

  def route(conv) do
    route(conv, conv.method, conv.path)
  end

  def route(conv, "GET", "/wildthings") do
    %{conv | resp_body: "Bears, Lions, Tigers"}
  end

  def route(conv, "GET", "/bears") do
    %{conv | resp_body: "Bears"}
  end

  def route(conv, "GET", "/bears/" <> id) when id == "1" do
    %{conv | resp_body: "Bear #{id}"}
  end

  def route(conv, method, path) do
    %{conv | resp_body: "Can't #{method} #{path} here", status: 404}
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
