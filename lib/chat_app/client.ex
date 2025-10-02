defmodule ChatApp.Client do
  @moduledoc """
  Handles communication with a single client.
  - Greeting and username prompt
  - Command handling (/help, /join, /leave, /who, /quit)
  - Sending messages via Channel.broadcast
  - Closes connection properly on disconnect
  """

  require Logger

  def start(socket) do
    send_line(socket, "Welcome! Please enter your username:")

    case recv_line(socket) do
      {:ok, username} ->
        username = String.trim(username)
        send_line(socket, "Hello #{username}! Type /help for commands.")
        loop(%{socket: socket, username: username, channel: nil})

      {:error, _} ->
        close(socket)
    end
  end

  defp loop(state) do
    case recv_line(state.socket) do
      {:ok, line} ->
        line = String.trim(line)

        cond do
          line == "" ->
            loop(state)

          String.starts_with?(line, "/") ->
            state = handle_command(line, state)
            loop(state)

          true ->
            if state.channel do
              ChatApp.Channel.broadcast(state.channel, "[#{state.username}] #{line}")
              loop(state)
            else
              send_line(state.socket, "You are not in any channels. Use /join <name> or /list")
              loop(state)
            end
        end

      {:error, :closed} ->
        Logger.info("Client disconnected #{inspect self()}")
        leave_channel(state)
        close(state.socket)

      {:error, _} ->
        leave_channel(state)
        close(state.socket)
    end
  end

  # Commands
  defp handle_command("/help", state) do
    send_line(state.socket, """
    Available commands:
    /list                - shows active channels
    /join <name>         - join or create a channel
    /leave               - leave the current channel
    /who <channel>       - show users in the channel
    /quit                - end the connection
    """)
    state
  end

  defp handle_command("/list", state) do
    channels = ChatApp.Channel.list_channels()
    if channels == [] do
      send_line(state.socket, "No active channels.")
    else
      send_line(state.socket, "Active channels: #{Enum.join(channels, ", ")}")
    end
    state
  end

  defp handle_command("/join " <> rest, state) do
    channel = String.trim(rest)
    leave_channel(state)

    case ChatApp.ChannelFactory.create(channel) do
      {:ok, pid} ->
        ChatApp.Channel.join(pid, self(), state.username, state.socket)
        send_line(state.socket, "Joined: #{channel}")
        %{state | channel: channel}

      {:error, reason} ->
        send_line(state.socket, "Error joining the channel: #{inspect(reason)}")
        state
    end
  end

  defp handle_command("/leave", state) do
    leave_channel(state)
    %{state | channel: nil}
  end

  defp handle_command("/who " <> rest, state) do
    channel = String.trim(rest)

    case ChatApp.Channel.whereis(channel) do
      nil ->
        send_line(state.socket, "Channel #{channel} does not exist.")
      pid ->
        users = ChatApp.Channel.users(pid)
        send_line(state.socket, "Users in #{channel}: #{Enum.join(users, ", ")}")
    end

    state
  end

  defp handle_command("/quit", state) do
    send_line(state.socket, "Bye!")
    leave_channel(state)
    close(state.socket)
    exit(:normal)
  end

  defp handle_command(_unknown, state) do
    send_line(state.socket, "Unknown command. /help for list.")
    state
  end

  defp leave_channel(%{channel: nil}), do: :ok
  defp leave_channel(%{channel: chan, username: username}) when not is_nil(chan) do
    case ChatApp.Channel.whereis(chan) do
      nil -> :ok
      pid -> ChatApp.Channel.leave(pid, self(), username)
    end
  end

  defp recv_line(socket), do: :gen_tcp.recv(socket, 0)

  defp send_line(socket, text) do
    :gen_tcp.send(socket, text <> "\n")
  rescue
    _ -> :ok
  end

  defp close(socket) do
    try do
      :gen_tcp.close(socket)
    rescue
      _ -> :ok
    end
  end
end
