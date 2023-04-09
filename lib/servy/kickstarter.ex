defmodule Servy.Kickstarter do
  use GenServer

  def start_link(_) do
    if Mix.env() == :dev, do: IO.puts("Starting #{inspect(__MODULE__)}")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_http_server_pid do
    GenServer.call(__MODULE__, :get_http_server_pid)
  end

  def init(:ok) do
    Process.flag(:trap_exit, true)
    http_server_pid = start_http_server()
    {:ok, http_server_pid}
  end

  def handle_info({:EXIT, _http_server_pid = state, _reason}, state) do
    http_server_pid = start_http_server()
    {:noreply, http_server_pid}
  end

  def handle_call(:get_http_server_pid, _from, state) do
    {:reply, state, state}
  end

  defp start_http_server() do
    spawn_link(Servy.HttpServer, :start, [4000])
  end
end
