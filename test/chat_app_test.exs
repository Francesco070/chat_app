defmodule ChatAppTest do
  use ExUnit.Case

  test "MessageStrategy.shout macht Text GROSS" do
    assert ChatApp.MessageStrategy.shout("hallo") == "HALLO"
  end

  test "MessageStrategy.plain lässt Text unverändert" do
    assert ChatApp.MessageStrategy.plain("test123") == "test123"
  end

  test "MessageStrategy.bracket fügt '[Message]' hinzu" do
    assert ChatApp.MessageStrategy.bracket("abc") == "[Message] abc"
  end

  test "Channel kann gestartet und gefunden werden" do
    {:ok, pid} = ChatApp.Channel.start_link("testchannel")
    assert is_pid(pid)
    assert ChatApp.Channel.whereis("testchannel") == pid
  end

  test "Channel akzeptiert einen Join und liefert User-Liste zurück" do
    {:ok, pid} = ChatApp.Channel.start_link("joinchannel")

    {:ok, sock} = :gen_tcp.listen(0, [:binary, active: false])

    ChatApp.Channel.join(pid, self(), "alice", sock)
    users = ChatApp.Channel.users(pid)

    assert "alice" in users
  end

  test "Channel broadcastet Nachricht mit Strategy" do
    {:ok, pid} = ChatApp.Channel.start_link("broadcastchannel")

    {:ok, sock} = :gen_tcp.listen(0, [:binary, active: false])
    ChatApp.Channel.join(pid, self(), "bob", sock)

    ChatApp.Channel.broadcast(pid, "hello", &ChatApp.MessageStrategy.plain/1)
    ChatApp.Channel.broadcast(pid, "achtung", &ChatApp.MessageStrategy.shout/1)

    assert true
  end
end
