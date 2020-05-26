defmodule Chats.MixProject do
  use Mix.Project

  def project do
    [
      app: :chats,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # [applications: [:amqp]],
      # extra_applications: [:logger],
      extra_applications: [:logger, :amqp],
      mod: {Chats.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.0", override: true},
      {:plug, "~> 1.6"},
      {:cowboy, "~> 2.4"},
      {:plug_cowboy, "~> 2.0"},
      {:timex, "~> 3.0"},
      {:jsonapi, "~> 0.3.0"},
      {:joken, "~> 2.2.0"},
#      {:myxql, "~> 0.3.0"},
      {:ecto, "~> 2.0"},
      {:mariaex, "~> 0.7"},
      {:amqp, "~> 1.0"},
      {:httpotion, "~> 3.1.0"}
    ]
  end
end
