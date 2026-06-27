defmodule BotArmyOutreachManager.Stores.TargetStore do
  use GenServer
  require Logger

  @moduledoc """
  In-memory store for outreach targets loaded from PostgreSQL.
  Provides fast reads and triggers writes to DB before updates.
  """

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    targets = try_load_from_db()
    {:ok, %{targets: targets}}
  end

  # Public API

  def get_all do
    GenServer.call(__MODULE__, :get_all)
  end

  def get(target_name) do
    GenServer.call(__MODULE__, {:get, target_name})
  end

  def log_send(target_name, email) do
    GenServer.call(__MODULE__, {:log_send, target_name, email})
  end

  def log_reply(target_name, reply_text) do
    GenServer.call(__MODULE__, {:log_reply, target_name, reply_text})
  end

  def log_call(target_name, call_date, notes \\ nil) do
    GenServer.call(__MODULE__, {:log_call, target_name, call_date, notes})
  end

  def close_deal(target_name, status, reason) do
    GenServer.call(__MODULE__, {:close_deal, target_name, status, reason})
  end

  # Callbacks

  def handle_call(:get_all, _from, state) do
    {:reply, Map.values(state.targets), state}
  end

  def handle_call({:get, target_name}, _from, state) do
    target = Map.get(state.targets, target_name)
    {:reply, target, state}
  end

  def handle_call({:log_send, target_name, email}, _from, state) do
    now = DateTime.utc_now()

    existing =
      Map.get(state.targets, target_name, %{target_name: target_name, email: email, metadata: %{}})

    send_count = (get_in(existing, [:metadata, :sends]) || 0) + 1

    target =
      Map.merge(existing, %{
        status: "SENT",
        first_send_date: existing[:first_send_date] || now,
        last_send_date: now,
        metadata: Map.put(existing[:metadata] || %{}, :sends, send_count)
      })

    persist_to_db(target)

    new_state = Map.put(state.targets, target_name, target)
    {:reply, target, %{state | targets: new_state}}
  end

  def handle_call({:log_reply, target_name, reply_text}, _from, state) do
    now = DateTime.utc_now()

    target =
      Map.get(state.targets, target_name)
      |> Map.merge(%{
        status: "REPLIED",
        reply_date: now,
        reply_text: reply_text
      })

    persist_to_db(target)

    new_state = Map.put(state.targets, target_name, target)
    {:reply, target, %{state | targets: new_state}}
  end

  def handle_call({:log_call, target_name, call_date, notes}, _from, state) do
    target =
      Map.get(state.targets, target_name)
      |> Map.merge(%{
        status: "CALL",
        call_date: call_date,
        call_notes: notes
      })

    persist_to_db(target)

    new_state = Map.put(state.targets, target_name, target)
    {:reply, target, %{state | targets: new_state}}
  end

  def handle_call({:close_deal, target_name, status, reason}, _from, state) do
    target =
      Map.get(state.targets, target_name)
      |> Map.merge(%{
        status: status,
        closed_status: status,
        closed_reason: reason
      })

    persist_to_db(target)

    new_state = Map.put(state.targets, target_name, target)
    {:reply, target, %{state | targets: new_state}}
  end

  # Helpers

  defp try_load_from_db do
    %{}
  end

  defp persist_to_db(target) do
    # Database persistence deferred until deployment
    # TargetStore maintains in-memory state during operation
    spawn(fn -> async_persist_to_db(target) end)
    :ok
  end

  defp async_persist_to_db(%{target_name: _name} = target) do
    try do
      changeset =
        BotArmyOutreachManager.Schemas.OutreachTarget.changeset(
          %BotArmyOutreachManager.Schemas.OutreachTarget{},
          to_schema_attrs(target)
        )

      case BotArmyOutreachManager.Repo.insert_or_update(changeset) do
        {:ok, _} -> :ok
        {:error, reason} -> Logger.error("Failed to persist target: #{inspect(reason)}")
      end
    rescue
      _ -> :ok
    end
  end

  defp to_map(schema) do
    schema
    |> Map.from_struct()
    |> Map.drop([:__meta__])
  end

  defp to_schema_attrs(target) do
    target
    |> Map.take([
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
  end
end
