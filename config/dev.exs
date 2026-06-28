import Config

config :bot_army_outreach_manager, BotArmyOutreachManager.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 35432,
  database: "bot_army_outreach_manager_dev",
  stacktrace: true,
  show_sensitive_data_on_error: true,
  pool_size: 10
