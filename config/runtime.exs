import Config

if config_env() == :prod do
  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :bot_army_outreach_manager, BotArmyOutreachManager.Repo,
    username: System.get_env("DB_USER") || "postgres",
    password: System.get_env("DB_PASS") || "postgres",
    database: System.get_env("DB_NAME") || "bot_army_outreach_manager",
    hostname: System.get_env("DB_HOST") || "localhost",
    port: String.to_integer(System.get_env("DB_PORT") || "5432"),
    socket_options: maybe_ipv6,
    url: System.get_env("DATABASE_URL"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "20")
end
