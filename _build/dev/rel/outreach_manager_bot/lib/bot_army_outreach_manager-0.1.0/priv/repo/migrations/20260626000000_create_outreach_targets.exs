defmodule BotArmyOutreachManager.Repo.Migrations.CreateOutreachTargets do
  use Ecto.Migration

  def change do
    create table(:outreach_targets) do
      add(:target_name, :string, null: false)
      add(:email, :string, null: false)
      add(:status, :string, default: "QUEUED", null: false)
      add(:first_send_date, :utc_datetime)
      add(:last_send_date, :utc_datetime)
      add(:reply_date, :utc_datetime)
      add(:reply_text, :text)
      add(:call_date, :utc_datetime)
      add(:call_notes, :text)
      add(:closed_status, :string)
      add(:closed_reason, :text)
      add(:metadata, :map, default: %{})

      timestamps(type: :utc_datetime)
    end

    create(unique_index(:outreach_targets, [:target_name]))
  end
end
