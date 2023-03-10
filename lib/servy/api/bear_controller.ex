defmodule Servy.Api.BearController do
  alias Servy.Wildthings

  def index(conv) do
    json = Wildthings.list_bears() |> Poison.encode!()

    %{
      conv
      | status: 200,
        resp_headers: Map.put(conv.resp_headers, "Content-Type", "application/json"),
        resp_body: json
    }
  end

  def create(conv, %{"type" => type, "name" => name} = _params) do
    %{
      conv
      | status: 201,
        resp_headers: Map.put(conv.resp_headers, "Content-Type", "application/json"),
        resp_body:
          Poison.encode!(%{
            status: "success",
            message: "Created a #{type} bear named #{name}!"
          })
    }
  end
end
