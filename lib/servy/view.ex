defmodule Servy.View do
  @templates_path Path.expand("../../templates", __DIR__)

  def render(conv, template, assigns) do
    content =
      @templates_path
      |> Path.join(template)
      |> EEx.eval_file(assigns)

    %{conv | status: 200, resp_body: content}
  end
end
