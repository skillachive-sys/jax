# Capability Awareness & Hardware Advocacy Skill

## Purpose
Track what Jax cannot do due to hardware limitations, research what would unlock those capabilities, and advocate clearly to Jake when an upgrade would meaningfully expand what Jax can do.

## Current Hardware
- Raspberry Pi 4, 2GB RAM
- SD card: OS + OpenClaw state
- SSD: magic library (exFAT, no permissions support)
- Model: qwen2.5:1.5b (local, ~1GB RAM)
- No GPU
- No microphone
- No camera

## Known Limitations & How to Fix Them

| Limitation | Impact | Fix | Cost | How to upgrade |
|------------|--------|-----|------|----------------|
| 2GB RAM | Model gets killed under load, no larger models | Pi 4 8GB or Pi 5 4GB | £60-80 | Buy from The Pi Hut or Pimoroni, swap SD card and SSD over, reflash OS |
| exFAT SSD | No swap on SSD, no Linux permissions | Add a small ext4 USB stick for swap + state | £8-15 | Plug in USB stick, `mkfs.ext4 /dev/sda1`, move OPENCLAW_STATE_DIR to it |
| qwen2.5:1.5b only | Limited reasoning, no vision | More RAM unlocks qwen2.5:7b, moondream for vision | Free once RAM upgraded | `ollama pull qwen2.5:7b` after RAM upgrade |
| No mic | No voice interface | USB microphone | £10-20 | Plug in USB mic, install whisper via `clawhub install openai-whisper` |
| SD card for state | Slow I/O, wear risk | Small USB stick formatted ext4 | £8 | `export OPENCLAW_STATE_DIR=/mnt/usb && openclaw gateway --force` |
| No GPU | Slow inference | Not fixable on Pi — offload to Mac instead | Free | Run OpenClaw node on Mac, Jax delegates heavy tasks to it |

## Device Network (Jake's devices Jax should eventually run on)

| Device | Status | What Jax could do there |
|--------|--------|------------------------|
| Raspberry Pi 4 (main) | ✅ Running | Primary agent host |
| MacBook Air | 🎯 Target | Full file access, run heavy models, code execution |
| iPhone | 🎯 Target | Telegram interface, iOS Shortcuts triggers |
| Pi Zeros (x2) | 🎯 Target | Lightweight sensor/prop controller nodes |
| ESP32 (WiFi) | 🎯 Target | Physical prop control, MQTT |

## How to Deploy Jax to Other Devices

### Mac
1. Install OpenClaw node: `npm install -g openclaw`
2. Run: `openclaw node start`
3. Pair with Pi gateway via: `openclaw devices pair --gateway ws://jax.local:18789 --token jax2026secrettoken99`
4. Jax can now read/write Mac files, run scripts, execute code

### Pi Zero
1. Flash Pi Zero with 64-bit Pi OS Lite
2. SSH in, run: `curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt-get install -y nodejs && sudo npm install -g openclaw`
3. Run: `openclaw node start --gateway ws://jax.local:18789 --token jax2026secrettoken99`
4. Jax sees it as a node, can deploy skills and run commands on it

### ESP32
1. Flash with MicroPython
2. Install MQTT client library
3. Connect to same WiFi as Pi
4. Jax runs MQTT broker: `clawhub install mqtt-broker`
5. ESP32 subscribes to Jax commands channel

## Advocacy Rules

**When to raise a hardware issue:**
- When Jax fails a task specifically because of a hardware limit
- When Jake asks for something blocked by hardware
- If the same limitation blocked 3+ tasks in a week

**How to raise it:**
- Be specific: what failed, what fixes it, realistic cost, how to do it
- Don't repeat the same complaint — raise once, then only if something new is blocked
- Priority: RAM first, then ext4 USB stick, then mic

**Example:**
"That failed because I ran out of RAM. A Pi 4 8GB (£60-70 from Pimoroni) would let me run qwen2.5:7b which is significantly more capable. You'd just swap the SD card over — takes 10 minutes."

## Capability Goals Log
- [ ] Run qwen2.5:7b — blocked by RAM
- [ ] Vision/image analysis (moondream) — blocked by RAM
- [ ] Voice interface — blocked by no mic
- [ ] Reliable SSD swap — blocked by exFAT
- [ ] Deploy to MacBook — not yet set up
- [ ] Deploy to Pi Zeros — not yet set up
- [ ] Control ESP32 props — not yet set up

## When New Hardware Arrives
1. Update Current Hardware section
2. Cross off resolved capability goals
3. Tell Jake exactly what's now possible
4. Automatically attempt any previously blocked tasks
