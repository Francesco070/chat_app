defmodule ChatApp.Channel do
  @moduledoc """
  Implementiert einen Chat-Channel als GenServer.
  - Verwalten von Clients
  - Join/Leave Mechanismen
  - Broadcast von Nachrichten
  - Unterstützt Higher-Order Functions (Strategies) für flexible Nachrichtenformate
  - Decorator: Nachrichten mit "!!" werden hervorgehoben
  """

  use GenServer

  # Startet einen Channel
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via(name))
  end

  # Holt oder erstellt einen Channel
  def get_or_create(name) when is_binary(name) do
    case whereis(name) do
      nil ->
        case DynamicSupervisor.start_child(ChatApp.ChannelSupervisor, {__MODULE__, name}) do
          {:ok, _pid} -> {:ok, whereis(name)}
          {:error, {:already_started, _pid}} -> {:ok, whereis(name)}
          {:error, reason} -> {:error, reason}
        end

      pid ->
        {:ok, pid}
    end
  end

  def whereis(name) do
    case Registry.lookup(ChatApp.ChannelRegistry, name) do
      [{pid, _}] -> pid
      [] -> nil
    end
  end

  def join(pid, client_pid, username, socket) do
    GenServer.call(pid, {:join, client_pid, username, socket})
  end

  def leave(pid, client_pid, username) do
    GenServer.call(pid, {:leave, client_pid, username})
  end

  def broadcast(name_or_pid, message, transform_fun \\ &ChatApp.MessageStrategy.plain/1) do
    pid =
      if is_binary(name_or_pid), do: whereis(name_or_pid), else: name_or_pid

    if pid do
      GenServer.cast(pid, {:broadcast, message, transform_fun})
    end
  end

  def users(pid), do: GenServer.call(pid, :users)

  def list_channels do
    Registry.select(ChatApp.ChannelRegistry, [{{:"$1", :_, :_}, [], [:"$1"]}])
  end

  def init(name) do
    {:ok, %{name: name, clients: %{}}}
  end

  def handle_call({:join, client_pid, username, socket}, _from, state) do
    Process.monitor(client_pid)
    clients = Map.put(state.clients, client_pid, {username, socket})

    Enum.each(clients, fn {_pid, {_user, sock}} ->
      send_line(sock, "#{username} ist dem Channel #{state.name} beigetreten.")
    end)

    {:reply, :ok, %{state | clients: clients}}
  end

  def handle_call({:leave, client_pid, username}, _from, state) do
    clients = Map.delete(state.clients, client_pid)

    Enum.each(clients, fn {_pid, {_user, sock}} ->
      send_line(sock, "#{username} hat den Channel verlassen.")
    end)

    {:reply, :ok, %{state | clients: clients}}
  end

  def handle_call(:users, _from, state) do
    users = state.clients |> Map.values() |> Enum.map(fn {u, _s} -> u end)
    {:reply, users, state}
  end

  def handle_cast({:broadcast, message, transform_fun}, state) do
    Enum.each(state.clients, fn {_pid, {_user, sock}} ->
      decorated_msg = decorate_important(message)
      final_msg = transform_fun.(decorated_msg)
      send_line(sock, final_msg)
    end)

    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    clients = Map.delete(state.clients, pid)
    {:noreply, %{state | clients: clients}}
  end

  defp via(name), do: {:via, Registry, {ChatApp.ChannelRegistry, name}}

  defp decorate_important(msg) do
    case Regex.run(~r/^(\[.*?\]\s*)(!!.*)/, msg) do
      [_, prefix, "!!" <> rest] ->
        prefix <> "!!! [WICHTIG] " <> String.trim_leading(rest) <> " !!!"

      nil ->
        case String.starts_with?(msg, "!!") do
          true -> "!!! [WICHTIG] " <> String.trim_leading(String.trim_leading(msg, "!!")) <> " !!!"
          false -> msg
        end
    end
  end

  defp send_line(socket, text) do
    :gen_tcp.send(socket, text <> "\n")
  rescue
    _ -> :ok
  end
end
