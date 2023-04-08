defmodule Servy.ServicesSupervisor do
  use Supervisor

  def start_link() do
    if Mix.env() == :dev, do: IO.puts("Starting #{inspect(__MODULE__)}")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {Servy.HitCounterDiy, %{}},
      {Servy.PledgeServer, %Servy.PledgeServer{}},
      Servy.SensorServer
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
