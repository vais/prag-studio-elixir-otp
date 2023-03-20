defmodule Servy.HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer

  setup do
    spawn(HttpServer, :start, [4000])
    :ok
  end

  test "/sensors" do
    {:ok, res} = HTTPoison.get("http://localhost:4000/sensors")

    assert res.status_code == 200

    expected_body = %{
      "snapshots" => [
        "cam-1-snapshot.jpg",
        "cam-2-snapshot.jpg",
        "cam-3-snapshot.jpg"
      ],
      "smokey" => %{"lat" => "48.7596 N", "lng" => "113.7870 W"}
    }

    body =
      res.body
      |> Poison.decode!()

    assert body == expected_body
  end
end
