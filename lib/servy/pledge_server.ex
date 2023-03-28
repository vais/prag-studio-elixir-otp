defmodule Servy.PledgeServer.GenericServer do
  require Logger

  def start(callback_module, initial_state) do
    maybe_start(Process.whereis(callback_module), callback_module, initial_state)
  end

  defp maybe_start(_pid = nil, callback_module, initial_state) do
    pid = spawn(__MODULE__, :loop, [callback_module, initial_state])
    Process.register(pid, callback_module)
    pid
  end

  defp maybe_start(pid, _mod, _state), do: pid

  def loop(callback_module, state) do
    receive do
      {:call, caller, message} when is_pid(caller) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send(caller, {:response, response})
        loop(callback_module, new_state)

      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        loop(callback_module, new_state)

      unexpected ->
        Logger.error("Unexpected message: #{inspect(unexpected)}")
        loop(callback_module, state)
    end
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:response, response} -> response
    end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end
end

defmodule Servy.PledgeServer do
  alias Servy.PledgeServer.GenericServer

  def start(pledges) do
    GenericServer.start(__MODULE__, pledges)
  end

  def handle_call(:total_pledged, state) do
    total_pledged = Enum.reduce(state, 0, fn {_name, amount}, acc -> acc + amount end)
    {total_pledged, state}
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call({:create_pledge, name, amount}, state) do
    new_state = Enum.take([{name, amount} | state], 3)
    {:ok, new_state}
  end

  def handle_cast(:clear, _state) do
    []
  end

  def clear() do
    GenericServer.cast(__MODULE__, :clear)
  end

  def total_pledged do
    GenericServer.call(__MODULE__, :total_pledged)
  end

  def recent_pledges() do
    GenericServer.call(__MODULE__, :recent_pledges)
  end

  def create_pledge(name, amount) do
    {:ok, _id} = send_pledge_to_service(name, amount)
    GenericServer.call(__MODULE__, {:create_pledge, name, amount})
  end

  def send_pledge_to_service(_name, _amount) do
    {:ok, generate_pledge_id()}
  end

  def generate_pledge_id(rng \\ fn -> :rand.uniform(1000) end) do
    rng.()
    |> Integer.to_string()
    |> String.pad_leading(4, ["0"])
    |> then(fn id -> "pledge-#{id}" end)
  end
end
