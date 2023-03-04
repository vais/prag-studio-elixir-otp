defmodule Servy.Plugins do
  require Logger

  alias Servy.Conv

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%Conv{path: path} = conv) do
    regex = ~r"^/(?<resource>\w+)\?id=(?<id>\d+)$"
    captures = Regex.named_captures(regex, path)
    rewrite_path(conv, captures)
  end

  defp rewrite_path(%Conv{} = conv, _captures = %{"resource" => resource, "id" => id}) do
    %{conv | path: "/#{resource}/#{id}"}
  end

  defp rewrite_path(%Conv{} = conv, _captures = nil), do: conv

  def emojify(%Conv{method: "GET", status: 200} = conv) do
    %{conv | resp_body: "👍 #{conv.resp_body} 🔥"}
  end

  def emojify(%Conv{} = conv), do: conv

  def track(%Conv{status: 404} = conv) do
    conv
    |> Map.take([:method, :path, :status])
    |> Map.values()
    |> Enum.join(" ")
    |> Logger.error()

    conv
  end

  def track(%Conv{} = conv), do: conv
end
