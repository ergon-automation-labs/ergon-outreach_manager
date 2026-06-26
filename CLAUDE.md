# Outreach Manager Bot

**Purpose:** NATS-based state management for sales outreach tracking (targets, sends, replies, calls, deals).

**Why a bot instead of Makefile?**
- Durable state in PostgreSQL, not JSON files
- Queryable via NATS subjects
- Shareable across operators
- Integrates with existing Bot Army infrastructure

---

## Architecture

### Core Components

1. **Stores**
   - `TargetStore` — GenServer maintaining in-memory target state, persisted to DB
   - Loads targets from PostgreSQL on startup
   - Writes all state changes back to DB before responding

2. **Schemas**
   - `OutreachTarget` — Ecto schema with fields: target_name, email, status, send dates, reply text, call info, deal closure

3. **NATS Handlers**
   - `send_handler` — `outreach.send.log` — Log a send, update status to SENT
   - `reply_handler` — `outreach.reply.log` — Log a reply with text, update to REPLIED
   - `call_handler` — `outreach.call.log` — Book a call with date + notes, update to CALL
   - `status_handler` — `outreach.status` — Return pipeline counts + full target list

---

## NATS Subjects

### Request-Reply

```
outreach.send.log     → Request: {target, email} → Response: {target, status, sent_date}
outreach.reply.log    → Request: {target, message} → Response: {target, status, replied_date}
outreach.call.log     → Request: {target, call_date, notes} → Response: {target, status, call_date}
outreach.status       → Request: {} → Response: {pipeline counts, target list}
```

### Bridge Façades (TODO)

```
bridge.outreach.send      → wrapper for outreach.send.log
bridge.outreach.reply     → wrapper for outreach.reply.log
bridge.outreach.call      → wrapper for outreach.call.log
bridge.outreach.status    → wrapper for outreach.status
```

---

## Status Field

- `QUEUED` — Drafted, not yet sent
- `SENT` — Initial send logged
- `REPLIED` — Got a response
- `CALL` — Meeting booked
- `CLOSED-WON` — Deal won
- `CLOSED-LOST` — Deal lost

---

## TODO: Complete Setup

- [ ] **Migrations** — Create `outreach_targets` table in PostgreSQL
- [ ] **Bridge Façades** — Add `bridge.outreach.*` subjects that wrap the bot
- [ ] **CLI** — Update Makefile to use NATS subjects instead of JSON files (backward compat)
- [ ] **Tests** — Add unit + integration tests for handlers
- [ ] **Scheduler** — Add 5-day bump reminder timer (publishes to Discord)
- [ ] **CSV Export** — Query targets and generate CSV dashboard

---

## Testing

```bash
# Unit tests (no NATS)
mix test

# Integration (hits real NATS + DB)
mix test --include integration

# Specific handler
mix test --only handlers
```

---

## Quick Start

Once migrations are in place and the bot is running on the NATS bridge:

```bash
# Check pipeline status
nats request nats://localhost:4222 outreach.status '{}'

# Log a send
nats request nats://localhost:4222 outreach.send.log '{"target":"Boris","email":"boris@example.com"}'

# Log a reply
nats request nats://localhost:4222 outreach.reply.log '{"target":"Boris","message":"Lets talk"}'

# Log a call
nats request nats://localhost:4222 outreach.call.log '{"target":"Boris","call_date":"2026-07-01T14:00:00Z","notes":"Discuss safeguard"}'
```

---

## Integration with Makefile CLI

The original Makefile in Agent_Operable_Repo_Contract_Service will be updated to call these NATS subjects instead of manipulating JSON files:

```bash
# Before (JSON files)
make outreach-log TARGET=... SENT_TO=...

# After (calls the bot)
make outreach-log TARGET=... SENT_TO=...
  → nats request nats://localhost:4222 outreach.send.log '{"target":"...","email":"..."}'
```

This keeps the CLI surface unchanged while moving the backend to a proper bot service.

---

## See Also

- `Makefile` — Build, test, deploy targets
- `test/` — Test files (to be expanded)
- `../CLAUDE.md` (elixir_bots) — Monorepo conventions
