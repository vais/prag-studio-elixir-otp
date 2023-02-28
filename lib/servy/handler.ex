defmodule Servy.Handler do
  defstruct method: nil, path: nil, status: nil, resp_body: nil

  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> route
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

  def rewrite_path(conv = %{path: "/wildlife"}) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(conv), do: conv

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
    |> IO.puts()

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
