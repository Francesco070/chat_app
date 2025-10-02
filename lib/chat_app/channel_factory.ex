defmodule ChatApp.ChannelFactory do
  @moduledoc """
  Factory Pattern: Encapsulates the creation of channels via the supervisor.
  """

  def create(name) do
    case ChatApp.Channel.get_or_create(name) do
      {:ok, pid} -> {:ok, pid}
      {:error, _} -> {:error, :cannot_create}
    end
  end
end
