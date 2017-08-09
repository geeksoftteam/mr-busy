defmodule MrBusy.Mixfile do
  use Mix.Project

  def project do
    [app: :mr_busy,
     version: "1.0.0",
     elixir: "~> 1.3",
     deps: deps()]
  end

  def application do
    [applications: [:logger, :poison]]
  end

  defp deps do
    [
      {:poison, "~> 2.2 or ~> 3.0"},
    ]
  end
end
