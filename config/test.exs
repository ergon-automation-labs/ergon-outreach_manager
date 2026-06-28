import Config

config :bot_army_outreach_manager, BotArmyOutreachManager.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 35432,
  database: "bot_army_outreach_manager_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10
