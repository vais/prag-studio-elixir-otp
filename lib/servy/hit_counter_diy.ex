defmodule Servy.HitCounterDiy do
  use GenServer
  require Logger

  def start(%{} = state) do
    case GenServer.start(__MODULE__, state, name: __MODULE__) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  def init(state) do
    {:ok, state}
  end

  def handle_info(other, state) do
    Logger.error("Unexpected message: #{inspect(other)}")
    {:noreply, state}
  end

  def handle_cast(:reset, _state) do
    {:noreply, %{}}
  end

  def handle_cast({:hit, path}, state) do
    {:noreply, Map.update(state, path, 1, &(&1 + 1))}
  end

  def handle_call({:get_count, path}, _from, state) do
    {:reply, Map.get(state, path, 0), state}
  end

  def handle_call(:report, _from, state) do
    {:reply, state, state}
  end

  def reset() do
    GenServer.cast(__MODULE__, :reset)
  end

  def hit(path) do
    GenServer.cast(__MODULE__, {:hit, path})
  end

  def get_count(path) do
    GenServer.call(__MODULE__, {:get_count, path})
  end

  def report do
    GenServer.call(__MODULE__, :report)
  end
end
