defmodule BotArmyOutreachManager.NATS.Handlers.SendHandler do
  use BotArmyCore.NATS.Handler

  @moduledoc """
  Handle outreach.send.log requests.
  Logs a send to the outreach target store.
  """

  subject("outreach.send.log")

  def handle_message(message, _context) do
    with {:ok, data} <- Jason.decode(message.data),
         target_name when not is_nil(target_name) <- Map.get(data, "target"),
         email when not is_nil(email) <- Map.get(data, "email") do
      target = BotArmyOutreachManager.Stores.TargetStore.log_send(target_name, email)

      Reply.ok(%{
        "data" => %{
          "target" => target.target_name,
          "status" => target.status,
          "sent_date" => target.last_send_date
        }
      })
    else
      :error -> Reply.error("Invalid JSON in request body")
      nil -> Reply.error("Missing required fields: target, email")
      error -> Reply.error("Error: #{inspect(error)}")
    end
  end
end
