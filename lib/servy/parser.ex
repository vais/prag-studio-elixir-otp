defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [head, body] = String.split(request, "\n\n")
    [request_line | header_lines] = String.split(head, "\n")
    [method, path, _version] = String.split(request_line, " ")
    headers = parse_headers(header_lines)
    params = parse_params(headers["Content-Type"], body, %{})

    %Conv{
      method: method,
      path: path,
      headers: headers,
      params: params
    }
  end

  defp parse_headers(header_lines) do
    Enum.reduce(header_lines, %{}, fn header_line, headers ->
      [key, value] = String.split(header_line, ": ")
      Map.put(headers, key, value)
    end)
  end

  defp parse_params(_content_type = "application/x-www-form-urlencoded", body, params) do
    body
    |> String.trim()
    |> URI.decode_query(params)
  end

  defp parse_params(_content_type, _body, params), do: params
end
