defmodule Servy do
  use Application

  def start(_type, _args) do
    if Mix.env() == :dev, do: IO.puts("Starting #{inspect(__MODULE__)}")
    Servy.Supervisor.start_link()
  end
end
