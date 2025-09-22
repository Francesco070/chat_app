defmodule ChatApp.Acceptor do
  require Logger

  def listen(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    Logger.info("Chat server listening on port #{port}")

    accept_loop(socket)
  end

  defp accept_loop(listen_socket) do
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)
    # spawn a process to handle the client
    pid = spawn(fn -> ChatApp.Client.start(client_socket) end)
    :gen_tcp.controlling_process(client_socket, pid)
    accept_loop(listen_socket)
  end
end
