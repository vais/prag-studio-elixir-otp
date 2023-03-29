defmodule Servy.HitCounterDiyTest do
  use ExUnit.Case

  alias Servy.HitCounterDiy, as: HitCounter

  setup do
    counter = HitCounter.start(%{})
    on_exit(fn -> Process.exit(counter, :shutdown) end)
  end

  test "counts hits" do
    HitCounter.hit("a")
    HitCounter.hit("a")
    HitCounter.hit("a")
    HitCounter.hit("z")

    assert HitCounter.get_count("a") == 3
    assert HitCounter.get_count("z") == 1
    assert HitCounter.get_count("x") == 0

    assert HitCounter.report() == %{"a" => 3, "z" => 1}

    HitCounter.reset()
    HitCounter.hit("z")
    assert HitCounter.report() == %{"z" => 1}
  end

  test "unexpected message" do
    log =
      ExUnit.CaptureLog.capture_log(fn ->
        send(HitCounter, "wat")
        Process.sleep(500)
      end)

    assert log =~ "Unexpected message: \"wat\""

    HitCounter.hit("a")
    assert HitCounter.get_count("a") == 1
  end
end
