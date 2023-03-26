defmodule Servy.HitCounterAgent do
  def start(initial_state) do
    maybe_start(initial_state, Process.whereis(__MODULE__))
  end

  defp maybe_start(initial_state, _pid = nil) do
    {:ok, pid} = Agent.start(fn -> initial_state end)
    Process.register(pid, __MODULE__)
    pid
  end

  defp maybe_start(_initial_state, pid), do: pid

  def hit(path) do
    Agent.update(__MODULE__, &Map.update(&1, path, 1, fn count -> count + 1 end))
  end

  def get_count(path) do
    Agent.get(__MODULE__, &Map.get(&1, path, 0))
  end

  def report do
    Agent.get(__MODULE__, fn map -> map end)
  end
end
