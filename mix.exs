defmodule Orchid.MixProject do
  use Mix.Project

  def project do
    [
      app: :orchid,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Orchid.Application, []},
      extra_applications: [:mnesia, :logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.12"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.2"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:git_cli, "~> 0.3"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},

      {:ash, "~> 3.0.0-rc"},
      {:ash_state_machine, "~> 0.2.3-rc.1"},
      {:bandit, "~> 1.2"},
      {:boundary, "~> 0.10.3"},
      {:ecto, "~> 3.11"},
      {:highlander, "~> 0.2"},
      {:req, "~> 0.4"},
      {:yaml_elixir, "~> 2.9"},
      {:local_cluster, "~> 1.2", only: [:test]}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind orchid", "esbuild orchid"],
      "assets.deploy": [
        "tailwind orchid --minify",
        "esbuild orchid --minify",
        "phx.digest"
      ],
      test: "test --no-start"
    ]
  end
end
