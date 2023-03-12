defmodule Servy.HttpServer do
  def start(port) when is_integer(port) and port > 1023 do
    {:ok, listen_socket} =
      :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])

    accept_loop(listen_socket)
  end

  defp accept_loop(listen_socket) do
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)
    serve(client_socket)
    accept_loop(listen_socket)
  end

  defp serve(client_socket) do
    client_socket
    |> read_request()
    |> Servy.Handler.handle()
    |> send_response(client_socket)
  end

  defp read_request(client_socket) do
    {:ok, request} = :gen_tcp.recv(client_socket, 0)
    request
  end

  defp send_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)
    :ok = :gen_tcp.close(client_socket)
  end
end
