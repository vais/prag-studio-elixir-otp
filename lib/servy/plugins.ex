defmodule Servy.Plugins do
  require Logger

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

  def emojify(%{method: "GET", status: 200} = conv) do
    %{conv | resp_body: "👍 #{conv.resp_body} 🔥"}
  end

  def emojify(conv), do: conv

  def track(%{status: 404} = conv) do
    conv
    |> Map.take([:method, :path, :status])
    |> Map.values()
    |> Enum.join(" ")
    |> Logger.error()

    conv
  end

  def track(conv), do: conv
end
