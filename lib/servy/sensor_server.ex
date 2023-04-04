defmodule Servy.SensorServer do
  defstruct sensor_data: %{}, refresh_interval: :timer.seconds(5)

  use GenServer

  alias Servy.{Tracker, VideoCam}

  def start() do
    GenServer.start(__MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  def get_sensor_data do
    GenServer.call(__MODULE__, :get_sensor_data)
  end

  def set_refresh_interval(refresh_interval) do
    GenServer.cast(__MODULE__, {:set_refresh_interval, refresh_interval})
  end

  def init(%__MODULE__{} = state) do
    sensor_data = fetch_sensor_data()
    schedule_refresh(state.refresh_interval)
    {:ok, %{state | sensor_data: sensor_data}}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state.sensor_data, state}
  end

  def handle_cast({:set_refresh_interval, refresh_interval}, state) do
    {:noreply, %{state | refresh_interval: refresh_interval}}
  end

  def handle_info(:refresh, state) do
    # IO.puts("#{Time.utc_now()} refreshing")
    sensor_data = fetch_sensor_data()
    schedule_refresh(state.refresh_interval)
    {:noreply, %{state | sensor_data: sensor_data}}
  end

  defp schedule_refresh(refresh_interval) do
    Process.send_after(self(), :refresh, refresh_interval)
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
