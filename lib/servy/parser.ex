defmodule Servy.Parser do
  alias Servy.Handler

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    %Handler{method: method, path: path}
  end
end
