defmodule Servy.PledgeServerTest do
  use ExUnit.Case

  alias Servy.PledgeServer

  setup do
    pledge_server = PledgeServer.start([])

    on_exit(fn ->
      Process.exit(pledge_server, :shutdown)
    end)
  end

  test "total_pledged" do
    PledgeServer.create_pledge("daphne", 100)
    PledgeServer.create_pledge("joe", 1)
    PledgeServer.create_pledge("moe", 3)
    PledgeServer.create_pledge("curly", 5)
    total_pledged = PledgeServer.total_pledged()
    assert total_pledged == 9
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
