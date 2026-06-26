defmodule BotArmyOutreachManager.NATS.Handlers.StatusHandler do
  use BotArmyCore.NATS.Handler

  @moduledoc """
  Handle outreach.status requests.
  Returns current pipeline counts and all targets.
  """

  subject("outreach.status")

  def handle_message(_message, _context) do
    targets = BotArmyOutreachManager.Stores.TargetStore.get_all()

    counts =
      targets
      |> Enum.group_by(& &1.status)
      |> Enum.map(fn {status, list} -> {status, Enum.count(list)} end)
      |> Enum.into(%{})

    target_list =
      Enum.map(targets, fn target ->
        %{
          "target" => target.target_name,
          "email" => target.email,
          "status" => target.status,
          "first_send_date" => target.first_send_date,
          "last_send_date" => target.last_send_date,
          "reply_date" => target.reply_date,
          "call_date" => target.call_date
        }
      end)

    Reply.ok(%{
      "data" => %{
        "pipeline" => %{
          "queued" => Map.get(counts, "QUEUED", 0),
          "sent" => Map.get(counts, "SENT", 0),
          "replied" => Map.get(counts, "REPLIED", 0),
          "call" => Map.get(counts, "CALL", 0),
          "closed_won" => Map.get(counts, "CLOSED-WON", 0),
          "closed_lost" => Map.get(counts, "CLOSED-LOST", 0)
        },
        "targets" => target_list
      }
    })
  end
end
