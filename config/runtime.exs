import Config

if config_env() == :prod do
  port = String.to_integer(System.get_env("PORT") || "4040")
  
  config :chat_app,
    port: port
end
