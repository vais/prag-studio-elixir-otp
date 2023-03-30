defmodule Servy.PledgeServerTest do
  use ExUnit.Case

  alias Servy.PledgeServer

  setup do
    {:ok, pledge_server} = PledgeServer.start([])

    on_exit(fn ->
      Process.exit(pledge_server, :shutdown)
    end)
  end

  test "unexpected message" do
    log =
      ExUnit.CaptureLog.capture_log(fn ->
        send(Servy.PledgeServer, "hello")
        Process.sleep(500)
      end)

    assert log =~ "unexpected message"
  end

  test "total_pledged" do
    PledgeServer.create_pledge("daphne", 100)
    PledgeServer.create_pledge("joe", 1)
    PledgeServer.create_pledge("moe", 3)
    PledgeServer.create_pledge("curly", 5)
    total_pledged = PledgeServer.total_pledged()
    assert total_pledged == 9
  end

  test "clear" do
    PledgeServer.create_pledge("joe", 1)
    PledgeServer.create_pledge("moe", 3)
    assert PledgeServer.recent_pledges() == [{"moe", 3}, {"joe", 1}]

    PledgeServer.clear()
    assert PledgeServer.recent_pledges() == []

    PledgeServer.create_pledge("curly", 5)
    assert PledgeServer.recent_pledges() == [{"curly", 5}]
  end

  test "generate id" do
    id = PledgeServer.generate_pledge_id(fn -> 1 end)
    assert id =~ "pledge-0001"

    id = PledgeServer.generate_pledge_id(fn -> 12 end)
    assert id =~ "pledge-0012"

    id = PledgeServer.generate_pledge_id(fn -> 123 end)
    assert id =~ "pledge-0123"

    id = PledgeServer.generate_pledge_id(fn -> 1234 end)
    assert id =~ "pledge-1234"

    id = PledgeServer.generate_pledge_id()
    assert id =~ ~r/^pledge-\d{4}$/
  end
end
