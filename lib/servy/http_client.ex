defmodule Servy.HttpClient do
  def send(request) do
    host = 'localhost'
    port = 4000
    options = [:binary, packet: :raw, active: false]
    {:ok, socket} = :gen_tcp.connect(host, port, options)
    :ok = :gen_tcp.send(socket, request)
    {:ok, response} = :gen_tcp.recv(socket, 0)
    :ok = :gen_tcp.close(socket)
    response
  end
end
