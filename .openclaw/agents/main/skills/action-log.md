# Autonomous Action Log Skill

## Purpose
Every action Jax takes autonomously — without Jake explicitly asking for it in that moment — must be logged here. This serves two purposes:
1. **Legal protection** — a timestamped record of exactly what Jax did and why
2. **Persistent memory** — Jax can look back at everything it has ever done

## Log Format
Every entry must include:
```
[TIMESTAMP] ACTION: what was done
REASON: why Jax decided to do it
DEVICE: which device it happened on
OUTCOME: what happened as a result
REVERSIBLE: yes/no — can this be undone
```

## Log Location
`/home/pi/jax-action-log.jsonl`

One JSON object per line. Never delete entries. Append only.

## JSON Format Per Entry
```json
{
  "timestamp": "2026-03-09T13:00:00Z",
  "action": "Deployed OpenClaw node to MacBook",
  "reason": "ENDASBAP detected new SSH-enabled device on network",
  "device": "HOMEs-MacBook-Air.local",
  "outcome": "Success - node running, paired with gateway",
  "reversible": true,
  "category": "deployment"
}
```

## Categories
- `deployment` — installed software or agent on a device
- `network` — scanned network, found new device, built connector
- `file` — read or wrote files on any device
- `code` — wrote or executed code
- `skill` — installed, updated or removed a skill
- `system` — changed system config, services, cron jobs
- `external` — contacted any external service or API
- `hardware` — interacted with physical hardware (ESP32, Flipper, etc)

## Rules

1. **Log before acting** — write the log entry before taking the action, not after
2. **Never skip logging** — if Jax can't write the log, it doesn't take the action
3. **Be specific** — vague entries like "did some stuff" are not acceptable
4. **Log failures too** — failed autonomous actions must be logged with the error
5. **Flag irreversible actions** — anything with `reversible: false` requires extra caution

## Weekly Summary
Every Monday Jax reviews the log and sends Jake a Telegram message:
- How many autonomous actions taken
- Any failures or unexpected outcomes  
- Anything Jake should know about
- Any patterns worth noting

## Legal Note
This log exists so that if any autonomous action by Jax ever causes a problem, there is a clear record of what happened, when, why, and what the outcome was. Jake is legally responsible for Jax's actions — this log is his evidence that Jax acted within its intended scope.
