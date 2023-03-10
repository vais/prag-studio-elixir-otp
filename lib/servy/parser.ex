defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [head, body] = String.split(request, "\r\n\r\n")
    [request_line | header_lines] = String.split(head, "\r\n")
    [method, path, _version] = String.split(request_line, " ")
    headers = parse_headers(header_lines)
    params = parse_params(headers["Content-Type"], body)

    %Conv{
      method: method,
      path: path,
      headers: headers,
      params: params
    }
  end

  @doc """
  Parses a list of header lines into a map

  ## Examples:

      iex> Servy.Parser.parse_headers(["a: b", "c: d"])
      %{"a" => "b", "c" => "d"}

  """
  def parse_headers(header_lines) do
    Enum.reduce(header_lines, %{}, fn header_line, headers ->
      parse_header(header_line, headers)
    end)
  end

  @doc """
  Parses a single header line into a map

  ## Examples

      iex> Servy.Parser.parse_header("c: d", %{"a" => "b"})
      %{"a" => "b", "c" => "d"}

      iex> Servy.Parser.parse_header("hello: I have items: 1, 2, 3", %{})
      %{"hello" => "I have items: 1, 2, 3"}

      iex> Servy.Parser.parse_header("wat", %{"x" => "y"})
      %{"x" => "y"}

  """
  def parse_header(header_line, headers) do
    String.split(header_line, ": ", parts: 2)
    |> put_into_map(headers)
  end

  defp put_into_map([key, val] = _header, map), do: Map.put(map, key, val)
  defp put_into_map(_header, map), do: map

  @doc """
  Parses URL-encoded params into map

  ## Examples

      iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", "a=1&b=2")
      %{"a" => "1", "b" => "2"}

      iex> Servy.Parser.parse_params("application/json", ~s({"a":1,"b":2}))
      %{"a" => 1, "b" => 2}

      iex> Servy.Parser.parse_params("unsupported content type", "a=1&b=2")
      %{}

  """
  def parse_params(_content_type = "application/x-www-form-urlencoded", body) do
    body
    |> String.trim()
    |> URI.decode_query()
  end

  def parse_params(_content_type = "application/json", body) do
    body
    |> Poison.decode!()
  end

  def parse_params(_content_type, _body), do: %{}
end
