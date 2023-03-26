defmodule Servy.HitCounterDiy do
  def start(%{} = state) do
    maybe_start(state, Process.whereis(__MODULE__))
  end

  defp maybe_start(state, nil) do
    pid = spawn(fn -> loop(state) end)
    Process.register(pid, __MODULE__)
    pid
  end

  defp maybe_start(_state, pid), do: pid

  defp loop(state) do
    receive do
      {:hit, path} ->
        new_state = Map.update(state, path, 1, &(&1 + 1))
        loop(new_state)

      {caller, :get_count, path} ->
        send(caller, {:count, Map.get(state, path, 0)})
        loop(state)

      {caller, :report} ->
        send(caller, {:report, state})
        loop(state)
    end
  end

  def hit(path) do
    send(__MODULE__, {:hit, path})
  end

  def get_count(path) do
    send(__MODULE__, {self(), :get_count, path})

    receive do
      {:count, count} -> count
    end
  end

  def report do
    send(__MODULE__, {self(), :report})

    receive do
      {:report, report} -> report
    end
  end
end
