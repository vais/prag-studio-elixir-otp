defmodule FourOhFourTest do
  use ExUnit.Case
  alias Servy.HttpServer
  alias Servy.HitCounterDiy, as: HitCounter

  @port 4000
  @base_url "http://localhost:#{@port}"

  setup do
    http_server = spawn(HttpServer, :start, [@port])
    {:ok, hit_counter} = HitCounter.start_link(%{})

    on_exit(fn ->
      for pid <- [http_server, hit_counter] do
        Process.exit(pid, :shutdown)
      end
    end)
  end

  test "getting a report of all 404s" do
    {:ok, res} = HTTPoison.get("#{@base_url}/abc")
    assert res.status_code == 404

    {:ok, res} = HTTPoison.get("#{@base_url}/abc")
    assert res.status_code == 404

    {:ok, res} = HTTPoison.get("#{@base_url}/def")
    assert res.status_code == 404

    {:ok, res} = HTTPoison.get("#{@base_url}/404s")
    assert res.status_code == 200
    assert res.body == ~s(%{"/abc" => 2, "/def" => 1})
  end
end
