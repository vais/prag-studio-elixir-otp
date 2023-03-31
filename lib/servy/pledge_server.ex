defmodule Servy.PledgeServer do
  use GenServer

  defstruct pledges: [], cache_size: 3

  def start(%__MODULE__{} = state \\ %__MODULE__{}) do
    GenServer.start(__MODULE__, state, name: __MODULE__)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_call(:total_pledged, _from, state) do
    total_pledged = Enum.reduce(state.pledges, 0, fn {_name, amount}, acc -> acc + amount end)
    {:reply, total_pledged, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    pledges =
      [{name, amount} | state.pledges]
      |> Enum.take(state.cache_size)

    new_state = %{state | pledges: pledges}

    {:reply, :ok, new_state}
  end

  def handle_call(:cache_size, _from, state) do
    {:reply, state.cache_size, state}
  end

  def handle_cast(:clear, _state) do
    {:noreply, %__MODULE__{}}
  end

  def handle_cast({:cache_size, size}, state) do
    pledges =
      state.pledges
      |> Enum.take(size)

    new_state = %{state | pledges: pledges, cache_size: size}

    {:noreply, new_state}
  end

  def cache_size(size) when is_integer(size) and size > 0 do
    GenServer.cast(__MODULE__, {:cache_size, size})
  end

  def cache_size() do
    GenServer.call(__MODULE__, :cache_size)
  end

  def clear() do
    GenServer.cast(__MODULE__, :clear)
  end

  def total_pledged do
    GenServer.call(__MODULE__, :total_pledged)
  end

  def recent_pledges() do
    GenServer.call(__MODULE__, :recent_pledges)
  end

  def create_pledge(name, amount) do
    {:ok, _id} = send_pledge_to_service(name, amount)
    GenServer.call(__MODULE__, {:create_pledge, name, amount})
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
