import Config

config :bot_army_outreach_manager, BotArmyOutreachManager.Repo,
  migration_primary_key: [type: :binary_id]

config :logger,
  level: :info

import_config "#{config_env()}.exs"
