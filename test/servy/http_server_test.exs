defmodule Servy.HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer

  test "the server" do
    spawn(HttpServer, :start, [4000])

    parent = self()

    bears = %{
      1 => "Teddy",
      2 => "Smokey",
      3 => "Paddington",
      4 => "Scarface",
      5 => "Snow"
    }

    for id <- Map.keys(bears) do
      spawn(fn ->
        {:ok, response} = HTTPoison.get("http://localhost:4000/bears/#{id}")
        send(parent, {:response, id, response})
      end)
    end

    for _ <- bears do
      receive do
        {:response, id, response} ->
          assert response.status_code == 200
          assert response.body =~ bears[id]
      end
    end
  end
end
