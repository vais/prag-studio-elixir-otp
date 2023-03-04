defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [head, body] = String.split(request, "\n\n")
    [request_line | _headers] = String.split(head, "\n")
    [method, path, _version] = String.split(request_line, " ")

    %Conv{
      method: method,
      path: path,
      params: parse_params(body)
    }
  end

  defp parse_params(params_string) do
    params_string
    |> String.trim()
    |> URI.decode_query()
  end
end
