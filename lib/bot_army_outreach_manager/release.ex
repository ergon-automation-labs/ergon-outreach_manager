defmodule BotArmyOutreachManager.Release do
  @moduledoc "Release tasks for database migrations and setup."

  require Logger

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _fun_return, _apps} =
        Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    :ok
  end

  def rollback(repo, version) do
    load_app()

    {:ok, _fun_return, _apps} =
      Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))

    :ok
  end

  defp repos do
    Application.load(:bot_army_outreach_manager)
    Application.fetch_env!(:bot_army_outreach_manager, :ecto_repos)
  end

  defp load_app do
    Application.load(:bot_army_outreach_manager)
  end
end
