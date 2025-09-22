defmodule ChatApp.Application do
  use Application

  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4040")

    children = [
      {Registry, keys: :unique, name: ChatApp.ChannelRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: ChatApp.ChannelSupervisor},
      {Task, fn -> ChatApp.Acceptor.listen(port) end}
    ]

    opts = [strategy: :one_for_one, name: ChatApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
