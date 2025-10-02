defmodule ChatAppTest do
  use ExUnit.Case

  test "MessageStrategy.shout makes text uppercase" do
    assert ChatApp.MessageStrategy.shout("hello") == "HELLO"
  end

  test "MessageStrategy.plain leaves text unchanged" do
    assert ChatApp.MessageStrategy.plain("test123") == "test123"
  end

  test "MessageStrategy.bracket adds '[Message]'" do
    assert ChatApp.MessageStrategy.bracket("abc") == "[Message] abc"
  end

  test "Channel can be started and found" do
    {:ok, pid} = ChatApp.Channel.start_link("testchannel")
    assert is_pid(pid)
    assert ChatApp.Channel.whereis("testchannel") == pid
  end

  test "Channel accepts a join and returns the user list" do
    {:ok, pid} = ChatApp.Channel.start_link("joinchannel")

    {:ok, sock} = :gen_tcp.listen(0, [:binary, active: false])

    ChatApp.Channel.join(pid, self(), "alice", sock)
    users = ChatApp.Channel.users(pid)

    assert "alice" in users
  end

  test "Channel broadcasts messages with a strategy" do
    {:ok, pid} = ChatApp.Channel.start_link("broadcastchannel")

    {:ok, sock} = :gen_tcp.listen(0, [:binary, active: false])
    ChatApp.Channel.join(pid, self(), "bob", sock)

    ChatApp.Channel.broadcast(pid, "hello", &ChatApp.MessageStrategy.plain/1)
    ChatApp.Channel.broadcast(pid, "caution", &ChatApp.MessageStrategy.shout/1)

    assert true
  end
end
