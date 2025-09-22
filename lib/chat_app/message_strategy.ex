defmodule ChatApp.MessageStrategy do
  @moduledoc """
  Strategy Pattern: Verschiedene Arten, Nachrichten zu formatieren.
  """

  def plain(msg), do: msg
  def shout(msg), do: String.upcase(msg)
  def bracket(msg), do: "[Message] #{msg}"
end
