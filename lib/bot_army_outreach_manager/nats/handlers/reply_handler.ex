defmodule BotArmyOutreachManager.NATS.Handlers.ReplyHandler do
  use BotArmyCore.NATS.Handler

  @moduledoc """
  Handle outreach.reply.log requests.
  Logs a reply and updates target status.
  """

  subject("outreach.reply.log")

  def handle_message(message, _context) do
    with {:ok, data} <- Jason.decode(message.data),
         target_name when not is_nil(target_name) <- Map.get(data, "target"),
         reply_text when not is_nil(reply_text) <- Map.get(data, "message") do
      target = BotArmyOutreachManager.Stores.TargetStore.log_reply(target_name, reply_text)

      Reply.ok(%{
        "data" => %{
          "target" => target.target_name,
          "status" => target.status,
          "replied_date" => target.reply_date
        }
      })
    else
      :error -> Reply.error("Invalid JSON in request body")
      nil -> Reply.error("Missing required fields: target, message")
      error -> Reply.error("Error: #{inspect(error)}")
    end
  end
end
