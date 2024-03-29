defmodule MyExpenses.MixProject do
  use Mix.Project

  def project do
    [
      app: :my_expenses,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),

      # Coveralls
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],

      # Docs
      name: "My_Expenses",
      source_url: "https://github.com/williamff11/my_expenses",
      docs: [main: "My_Expenses", extras: ["README.md"]]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {MyExpenses.Application, []},
      extra_applications: [:logger, :runtime_tools]
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
      {:ecto_sql, "~> 3.4"},
      {:ex_machina, "~> 2.7.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:jose, "~> 1.10.1"},
      {:phoenix, "~> 1.5.3"},
      {:phoenix_ecto, "~> 4.1"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_dashboard, "~> 0.2.0"},
      {:plug_cowboy, "~> 2.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:timex, "~> 3.6"},
      {:typed_struct, "~> 0.2.0"},
      {:uuid, "~> 1.1.8"},
      {:brcpfcnpj, "~> 0.1.0", only: [:dev, :test]},
      {:credo, "~> 1.5", only: [:dev, :test]},
      {:doctor, "~> 0.17.0", only: :dev},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:faker, "~> 0.15", only: [:dev, :test]}
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
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      # "ecto.seed": [&ecto_seed/1],
      # "myexpenses.seed": [
      #   "run priv/repo/myexpenses/seeds.sql"
      # ],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end

  # defp ecto_seed(_args) do
  #   Mix.Task.run("myexpenses.seed")
  #   Mix.Task.reenable("tenants.load")
  # end
end
