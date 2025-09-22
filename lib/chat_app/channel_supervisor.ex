defmodule ChatApp.ChannelSupervisor do
  use DynamicSupervisor

  def start_link(_), do: DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok), do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_channel(name) do
    child = {ChatApp.Channel, name}
    DynamicSupervisor.start_child(__MODULE__, child)
  end
end
