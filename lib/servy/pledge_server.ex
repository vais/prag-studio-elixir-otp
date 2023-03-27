defmodule Servy.PledgeServer do
  def start(pledges) do
    maybe_start(Process.whereis(__MODULE__), pledges)
  end

  defp maybe_start(_pid = nil, pledges) do
    pid = spawn(__MODULE__, :loop, [pledges])
    Process.register(pid, __MODULE__)
    pid
  end

  defp maybe_start(pid, _pledges), do: pid

  def loop(state) do
    receive do
      {caller, message} when is_pid(caller) ->
        {response, new_state} = handle_call(message, state)
        send(caller, {:response, response})
        loop(new_state)
    end
  end

  ### GenServer Serfver API ###

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

  ### GenServer Client API ###

  def call(pid, message) do
    send(pid, {self(), message})

    receive do
      {:response, response} -> response
    end
  end

  ############################

  def total_pledged do
    call(__MODULE__, :total_pledged)
  end

  def recent_pledges() do
    call(__MODULE__, :recent_pledges)
  end

  def create_pledge(name, amount) do
    {:ok, _id} = send_pledge_to_service(name, amount)
    call(__MODULE__, {:create_pledge, name, amount})
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
