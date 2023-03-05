defmodule Servy.BearController do
  alias Servy.Wildthings
  alias Servy.Bear

  defp bear_list_item(bear) do
    "<li>#{bear.name}</li>"
  end

  def index(conv) do
    items =
      Wildthings.list_bears()
      |> Enum.filter(&Bear.is_grizzly/1)
      |> Enum.sort(&Bear.order_asc_by_name/2)
      |> Enum.map(&bear_list_item/1)

    %{conv | status: 200, resp_body: "<ul>#{items}</ul>"}
  end

  def show(conv, %{"id" => id} = _params) do
    bear = Wildthings.get_bear(id)
    %{conv | status: 200, resp_body: "<h1>Bear #{bear.id}: #{bear.name}</h1>"}
  end

  def create(conv, %{"type" => type, "name" => name} = _params) do
    %{conv | status: 201, resp_body: "Created a #{type} bear named #{name}!"}
  end

  def create(conv, _params) do
    %{conv | status: 400, resp_body: "name and type are required fields"}
  end
end
