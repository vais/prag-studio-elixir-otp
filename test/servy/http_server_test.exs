defmodule Servy.HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer
  alias Servy.SensorServer

  setup do
    http_server = spawn(HttpServer, :start, [4000])
    {:ok, sensor_server} = SensorServer.start_link(:ok)

    on_exit(fn ->
      Process.exit(http_server, :shutdown)
      Process.exit(sensor_server, :shutdown)
    end)

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

  test "all good" do
    [
      "http://localhost:4000/wildthings",
      "http://localhost:4000/bears",
      "http://localhost:4000/bears/1",
      "http://localhost:4000/wildlife",
      "http://localhost:4000/api/bears"
    ]
    |> Enum.map(&Task.async(HTTPoison, :get, [&1]))
    |> Enum.map(&Task.await/1)
    |> Enum.each(fn {:ok, res} -> assert res.status_code == 200 end)
  end
end
