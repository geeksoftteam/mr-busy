defmodule MrBusy.Mixfile do
  use Mix.Project

  def project do
    [app: :mr_busy,
     version: "0.0.1",
     elixir: "~> 1.3.1",
     deps: deps]
  end

  def application do
    [applications: [:logger, :poison]]
  end

  defp deps do
    [
      {:poison, "~> 2.0"},
    ]
  end
end
