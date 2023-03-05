defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [head, body] = String.split(request, "\n\n")
    [request_line | header_lines] = String.split(head, "\n")
    [method, path, _version] = String.split(request_line, " ")
    headers = parse_headers(header_lines, %{})
    params = parse_params(headers["Content-Type"], body, %{})

    %Conv{
      method: method,
      path: path,
      headers: headers,
      params: params
    }
  end

  defp parse_headers([line | lines], %{} = headers) do
    [name, value] = String.split(line, ": ")
    parse_headers(lines, Map.put(headers, name, value))
  end

  defp parse_headers([], %{} = headers), do: headers

  defp parse_params(_content_type = "application/x-www-form-urlencoded", body, params) do
    body
    |> String.trim()
    |> URI.decode_query(params)
  end

  defp parse_params(_content_type, _body, params), do: params
end
