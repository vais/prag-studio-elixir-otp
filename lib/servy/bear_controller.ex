defmodule Servy.BearController do
  alias Servy.Wildthings
  alias Servy.Bear

  @templates_path Path.expand("../../templates", __DIR__)

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.filter(&Bear.is_grizzly/1)
      |> Enum.sort(&Bear.order_asc_by_name/2)

    render(conv, "index.eex", bears: bears)
  end

  def show(conv, %{"id" => id} = _params) do
    bear = Wildthings.get_bear(id)
    render(conv, "show.eex", bear: bear)
  end

  defp render(conv, template, assigns) do
    content =
      @templates_path
      |> Path.join(template)
      |> EEx.eval_file(assigns)

    %{conv | status: 200, resp_body: content}
  end

  def create(conv, %{"type" => type, "name" => name} = _params) do
    %{conv | status: 201, resp_body: "Created a #{type} bear named #{name}!"}
  end

  def create(conv, _params) do
    %{conv | status: 400, resp_body: "name and type are required fields"}
  end

  def delete(conv, _params) do
    %{conv | status: 403, resp_body: "Deleting bears is forbidden"}
  end
end
