defmodule BotArmyOutreachManager.Schemas.OutreachTarget do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Schema for tracking outreach targets, sends, replies, and calls.
  """

  schema "outreach_targets" do
    field(:target_name, :string)
    field(:email, :string)
    field(:status, :string, default: "QUEUED")
    field(:first_send_date, :utc_datetime)
    field(:last_send_date, :utc_datetime)
    field(:reply_date, :utc_datetime)
    field(:reply_text, :string)
    field(:call_date, :utc_datetime)
    field(:call_notes, :string)
    field(:closed_status, :string)
    field(:closed_reason, :string)
    field(:metadata, :map, default: %{})

    timestamps(type: :utc_datetime)
  end

  def changeset(target, attrs) do
    target
    |> cast(attrs, [
      :target_name,
      :email,
      :status,
      :first_send_date,
      :last_send_date,
      :reply_date,
      :reply_text,
      :call_date,
      :call_notes,
      :closed_status,
      :closed_reason,
      :metadata
    ])
    |> validate_required([:target_name, :email])
    |> validate_inclusion(:status, [
      "QUEUED",
      "SENT",
      "REPLIED",
      "CALL",
      "CLOSED-WON",
      "CLOSED-LOST"
    ])
  end
end
