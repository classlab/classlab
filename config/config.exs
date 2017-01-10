# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :classlab,
  ecto_repos: [Classlab.Repo]

config :classlab, Classlab.User,
  access_token_max_age: 60 * 15

# Configures the endpoint
config :classlab, Classlab.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "jbefga3gY9G+GB0S0NxH/iCoiCfc3x/eerCssXFpvrYWiB2J4tNP/ShI4JvCgELm",
  render_errors: [view: Classlab.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Classlab.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :quantum, cron: [
  "*/30 * * * *": {"Classlab.Jobs.MembershipAfterEventEmailJob", :perform_now}
]

# wkhtmltopdf
config :classlab, wkhtmltopdf_bin_path: "wkhtmltopdf"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
