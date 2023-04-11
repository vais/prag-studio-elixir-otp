defmodule Servy.PledgeControllerTest do
  use ExUnit.Case

  @url "http://localhost:4000/pledges"

  setup do
    Servy.PledgeServer.clear()
    :ok
  end

  test "GET /pledges" do
    {:ok, res} = HTTPoison.get(@url)

    assert res.status_code == 200
    assert res.body == "[]"
  end

  test "POST /pledges" do
    body = "name=Vais&amount=10"
    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

    {:ok, res} = HTTPoison.post(@url, body, headers)

    assert res.status_code == 201
    assert res.body == "Vais pledged 10"
  end

  test "caching the three most recent pledges" do
    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

    {:ok, _res} = HTTPoison.post(@url, "name=Mary&amount=100", headers)
    {:ok, res} = HTTPoison.get(@url)
    assert res.body == ~s([{"Mary", 100}])

    {:ok, _res} = HTTPoison.post(@url, "name=John&amount=22", headers)
    {:ok, res} = HTTPoison.get(@url)
    assert res.body == ~s([{"John", 22}, {"Mary", 100}])

    {:ok, _res} = HTTPoison.post(@url, "name=Ron&amount=10", headers)
    {:ok, res} = HTTPoison.get(@url)
    assert res.body == ~s([{"Ron", 10}, {"John", 22}, {"Mary", 100}])

    {:ok, _res} = HTTPoison.post(@url, "name=Steve&amount=20", headers)
    {:ok, res} = HTTPoison.get(@url)
    assert res.body == ~s([{"Steve", 20}, {"Ron", 10}, {"John", 22}])

    {:ok, _res} = HTTPoison.post(@url, "name=Jane&amount=24", headers)
    {:ok, res} = HTTPoison.get(@url)
    assert res.body == ~s([{"Jane", 24}, {"Steve", 20}, {"Ron", 10}])
  end
end
