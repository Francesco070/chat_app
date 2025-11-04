defmodule ChatApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :chat_app,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      releases: [
        chat_app: [
          include_executables_for: [:unix],
          applications: [runtime_tools: :permanent]
        ]
      ],
      deps: []
    ]
  end

  def application do
    [
      mod: {ChatApp.Application, []},
      extra_applications: [:logger]
    ]
  end
end
