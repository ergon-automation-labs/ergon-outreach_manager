defmodule BotArmyOutreachManager.NATS.Handlers.CallHandler do
  use BotArmyCore.NATS.Handler

  @moduledoc """
  Handle outreach.call.log requests.
  Logs a booked call with optional notes.
  """

  subject("outreach.call.log")

  def handle_message(message, _context) do
    with {:ok, data} <- Jason.decode(message.data),
         target_name when not is_nil(target_name) <- Map.get(data, "target"),
         call_date when not is_nil(call_date) <- Map.get(data, "call_date") do
      notes = Map.get(data, "notes")

      target = BotArmyOutreachManager.Stores.TargetStore.log_call(target_name, call_date, notes)

      Reply.ok(%{
        "data" => %{
          "target" => target.target_name,
          "status" => target.status,
          "call_date" => target.call_date,
          "notes" => target.call_notes
        }
      })
    else
      :error -> Reply.error("Invalid JSON in request body")
      nil -> Reply.error("Missing required fields: target, call_date")
      error -> Reply.error("Error: #{inspect(error)}")
    end
  end
end
