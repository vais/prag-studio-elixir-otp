defmodule Servy.SensorServer do
  use GenServer

  alias Servy.{Tracker, VideoCam}

  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def get_sensor_data do
    GenServer.call(__MODULE__, :get_sensor_data)
  end

  def init(_state) do
    initial_state = fetch_sensor_data()
    schedule_refresh()
    {:ok, initial_state}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:refresh, _state) do
    new_state = fetch_sensor_data()
    schedule_refresh()
    {:noreply, new_state}
  end

  defp schedule_refresh() do
    Process.send_after(self(), :refresh, :timer.seconds(5))
  end

  defp fetch_sensor_data do
    smokey = Task.async(Tracker, :get_location, ["smokey"])

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(VideoCam, :get_snapshot, [&1]))
      |> Enum.map(&Task.await/1)

    %{snapshots: snapshots, smokey: Task.await(smokey)}
  end
end
