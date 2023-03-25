defmodule Servy.PledgeServer do
  def start(pledges) do
    pid = spawn(__MODULE__, :loop, [pledges])
    Process.register(pid, __MODULE__)
    pid
  end

  def loop(state) do
    receive do
      {:create_pledge, name, amount} ->
        new_state = Enum.take([{name, amount} | state], 3)
        loop(new_state)

      {caller, :recent_pledges} ->
        send(caller, {:response, state})
        loop(state)

      {caller, :total_pledged} ->
        total_pledged = Enum.reduce(state, 0, fn {_name, amount}, acc -> acc + amount end)
        send(caller, {:response, total_pledged})
        loop(state)
    end
  end

  def total_pledged do
    send(__MODULE__, {self(), :total_pledged})

    receive do
      {:response, total_pledged} -> total_pledged
    end
  end

  def recent_pledges() do
    send(__MODULE__, {self(), :recent_pledges})

    receive do
      {:response, pledges} -> pledges
    end
  end

  def create_pledge(name, amount) do
    {:ok, _id} = send_pledge_to_service(name, amount)
    send(__MODULE__, {:create_pledge, name, amount})
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
