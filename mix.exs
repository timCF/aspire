defmodule Aspire.MixProject do
  use Mix.Project

  def project do
    [
      app: :aspire,
      version: ("VERSION" |> File.read! |> String.trim),
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # excoveralls
      test_coverage:      [tool: ExCoveralls],
      preferred_cli_env:  [
        coveralls:              :test,
        "coveralls.travis":     :test,
        "coveralls.circle":     :test,
        "coveralls.semaphore":  :test,
        "coveralls.post":       :test,
        "coveralls.detail":     :test,
        "coveralls.html":       :test,
      ],
      # dialyxir
      dialyzer:     [ignore_warnings: ".dialyzer_ignore"],
      # ex_doc
      name:         "Aspire",
      source_url:   "https://github.com/timCF/aspire",
      homepage_url: "https://github.com/timCF/aspire",
      docs:         [main: "Aspire", extras: ["README.md"]],
      # hex.pm stuff
      description:  "Each function performs type conversion if it is 100% safe. Else it returns first argument as is.",
      package: [
        licenses: ["Apache 2.0"],
        files: ["lib", "priv", "mix.exs", "README*", "VERSION*"],
        maintainers: ["Ilja Tkachuk aka timCF"],
        links: %{
          "GitHub" => "https://github.com/timCF/aspire",
          "Author's home page" => "https://timcf.github.io/",
        }
      ],
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # development tools
      {:excoveralls, "~> 0.8",            only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5",               only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19",                only: [:dev, :test], runtime: false},
      {:credo, "~> 0.8",                  only: [:dev, :test], runtime: false},
      {:boilex, "~> 0.1.6",               only: [:dev, :test], runtime: false},
      # test tools
      {:mock, "~> 0.3.0",                 only: [:dev, :test], runtime: false},
    ]
  end
end
