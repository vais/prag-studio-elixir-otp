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
  end
end
