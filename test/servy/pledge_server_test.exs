defmodule Servy.PledgeServerTest do
  use ExUnit.Case

  alias Servy.PledgeServer

  setup do
    PledgeServer.clear()
    :ok
  end

  test "unexpected message" do
    log =
      ExUnit.CaptureLog.capture_log(fn ->
        send(PledgeServer, "hello")
        Process.sleep(500)
      end)

    assert log =~ "unexpected message"
  end

  test "getting cache_size" do
    assert PledgeServer.cache_size() == 3
  end

  test "setting cache_size" do
    PledgeServer.cache_size(4)
    assert PledgeServer.cache_size() == 4
  end

  test "setting non-integer cache_size" do
    assert_raise FunctionClauseError, fn -> PledgeServer.cache_size(1.5) end
  end

  test "setting zero cache_size" do
    assert_raise FunctionClauseError, fn -> PledgeServer.cache_size(0) end
  end

  test "setting negative cache_size" do
    assert_raise FunctionClauseError, fn -> PledgeServer.cache_size(-2) end
  end

  test "putting cache_size to good use" do
    PledgeServer.cache_size(2)

    PledgeServer.create_pledge("daphne", 100)
    PledgeServer.create_pledge("joe", 1)
    PledgeServer.create_pledge("moe", 3)
    PledgeServer.create_pledge("curly", 5)

    assert PledgeServer.recent_pledges() == [
             {"curly", 5},
             {"moe", 3}
           ]

    PledgeServer.cache_size(4)

    PledgeServer.create_pledge("daphne", 100)
    PledgeServer.create_pledge("joe", 1)

    assert PledgeServer.recent_pledges() == [
             {"joe", 1},
             {"daphne", 100},
             {"curly", 5},
             {"moe", 3}
           ]

    PledgeServer.cache_size(2)

    assert PledgeServer.recent_pledges() == [
             {"joe", 1},
             {"daphne", 100}
           ]

    PledgeServer.cache_size(3)

    assert PledgeServer.recent_pledges() == [
             {"joe", 1},
             {"daphne", 100}
           ]
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
