defmodule ChatApp.MessageStrategy do
  @moduledoc """
  Strategy Pattern: Different ways to format messages.
  """

  def plain(msg), do: msg
  def shout(msg), do: String.upcase(msg)
  def bracket(msg), do: "[Message] #{msg}"
end
