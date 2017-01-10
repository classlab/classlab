defmodule Classlab.Mixfile do
  use Mix.Project

  def project do
    [app: :classlab,
     version: "0.0.1",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     deps_path: custom_deps_path(),
     build_path: custom_build_path(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test],
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Classlab, []},
     applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :bamboo, :bamboo_smtp, :quantum, :mariaex]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Please sort by name
  defp deps do
    [
      {:bamboo, "~> 0.7"},
      {:bamboo_smtp, "~> 1.2.1"},
      {:calecto, "~> 0.16.1"},
      {:calendar_translations, "~> 0.0.3"},
      {:calendar, "~> 0.16.0"},
      {:cowboy, "~> 1.0"},
      {:credo, "~> 0.5.1", only: [:dev, :test]},
      {:earmark, "~> 1.0.2"},
      {:excoveralls, "~> 0.5", only: :test},
      {:mariaex, ">= 0.7.0"},
      {:ex_doc, "~> 0.13", only: :dev},
      {:ex_machina, "~> 1.0", only: :test},
      {:gettext, "~> 0.13"},
      {:inch_ex, "~> 0.5", only: :docs},
      {:joken, "~> 1.3.1"},
      {:mix_test_watch, "~> 0.2", only: :dev},
      {:phoenix_ecto, "~> 3.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0.6", only: :dev},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix, "~> 1.2.1"},
      {:quantum, ">= 1.8.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "setup": ["ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "credo": ["credo --strict"],
      "s": ["phoenix.server"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  # You can't use symlinks to build and deps paths. So we have to set them
  # manually.
  defp custom_deps_path do
    if System.get_env("SEMAPHORE_CACHE_DIR") do
      System.get_env("SEMAPHORE_CACHE_DIR") <> "/deps"
    else
      "deps"
    end
  end

  defp custom_build_path do
    if System.get_env("SEMAPHORE_CACHE_DIR") do
      System.get_env("SEMAPHORE_CACHE_DIR") <> "/_build"
    else
      "_build"
    end
  end
end
