defmodule Servy.HitCounterDiy.GenericServer do
  require Logger

  def start(mod, %{} = state) do
    maybe_start(mod, state, Process.whereis(mod))
  end

  defp maybe_start(mod, state, nil) do
    pid = spawn(fn -> loop(mod, state) end)
    Process.register(pid, mod)
    pid
  end

  defp maybe_start(_mod, _state, pid), do: pid

  defp loop(mod, state) do
    receive do
      {:cast, message} ->
        new_state = mod.handle_cast(message, state)
        loop(mod, new_state)

      {:call, caller, message} ->
        {response, new_state} = mod.handle_call(message, state)
        send(caller, {:response, response})
        loop(mod, new_state)

      unexpected ->
        Logger.error("Unexpected message: #{inspect(unexpected)}")
        loop(mod, state)
    end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:response, response} -> response
    end
  end
end

defmodule Servy.HitCounterDiy do
  alias Servy.HitCounterDiy.GenericServer

  def start(%{} = state) do
    GenericServer.start(__MODULE__, state)
  end

  def handle_cast(:reset, _state) do
    %{}
  end

  def handle_cast({:hit, path}, state) do
    Map.update(state, path, 1, &(&1 + 1))
  end

  def handle_call({:get_count, path}, state) do
    {Map.get(state, path, 0), state}
  end

  def handle_call(:report, state) do
    {state, state}
  end

  def reset() do
    GenericServer.cast(__MODULE__, :reset)
  end

  def hit(path) do
    GenericServer.cast(__MODULE__, {:hit, path})
  end

  def get_count(path) do
    GenericServer.call(__MODULE__, {:get_count, path})
  end

  def report do
    GenericServer.call(__MODULE__, :report)
  end
end
