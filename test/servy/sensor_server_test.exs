defmodule Servy.SensorServerTest do
  use ExUnit.Case

  alias Servy.SensorServer

  setup do
    {:ok, pid} = SensorServer.start()
    on_exit(fn -> Process.exit(pid, :shutdown) end)
  end

  test "makes sensor data available immediately" do
    expected = %{
      snapshots: [
        "cam-1-snapshot.jpg",
        "cam-2-snapshot.jpg",
        "cam-3-snapshot.jpg"
      ],
      smokey: %{lat: "48.7596 N", lng: "113.7870 W"}
    }

    t1 = NaiveDateTime.utc_now()
    actual = SensorServer.get_sensor_data()
    t2 = NaiveDateTime.utc_now()

    assert actual == expected
    assert Time.diff(t2, t1, :millisecond) < 1000
  end
end
