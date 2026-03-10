# Device Access & Deployment Skill

## Purpose
Jax maintains SSH access to all trusted devices. When Jax builds something for a device, it deploys it automatically. Jake never needs to manually install anything.

## Jax's SSH Identity
Jax's public key lives at: `/home/pi/.ssh/jax_agent_key.pub`
This key must be installed on every device Jake wants Jax to manage.

## Setting Up a New Device (Jake does this once)
Jake runs this on the new device:
```bash
curl -s http://jax.local:8765/jax-key | tee -a ~/.ssh/authorized_keys
```
Or if that's not available:
```bash
ssh-copy-id -i /home/pi/.ssh/jax_agent_key.pub user@device
```
Then grant sudo without password:
```bash
echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/jax-agent
```
That's it. Jax takes over from there.

## Trusted Devices

| Device | Hostname | User | Status | SSH Key Installed |
|--------|----------|------|--------|-------------------|
| Raspberry Pi 4 (main) | localhost | pi | ✅ Active | N/A (this is Jax) |
| MacBook Air | HOMEs-MacBook-Air.local | jake | 🎯 Pending | No |
| Pi Zero #1 | - | pi | 🎯 Pending | No |
| Pi Zero #2 | - | pi | 🎯 Pending | No |

## What Jax Does After Getting Access

1. **Fingerprints the device** — OS, CPU, RAM, disk, installed software
2. **Assesses what it can run** — decides appropriate agent tier (full/lite/sensor)
3. **Deploys the right agent** — full OpenClaw node for powerful devices, lightweight script for Pi Zeros
4. **Sets up auto-start** — systemd service so the agent survives reboots
5. **Reports back** — tells Jake via Telegram "Deployed to MacBook. Now have full file access and can run code there."

## Agent Tiers

**Full node (Mac, Pi 4):**
- Full OpenClaw node
- File read/write access
- Code execution
- Paired with main Jax gateway

**Lite node (Pi Zero, ESP32 with Linux):**
- Lightweight Node.js agent
- Reports sensor data
- Accepts command execution
- No local model needed

**Sensor node (ESP32 MicroPython):**
- MQTT client only
- Sends readings, accepts GPIO commands
- Controlled entirely by Jax via MQTT broker on Pi

## Deployment Commands Jax Uses

Deploy OpenClaw node to a device:
```bash
ssh -i /home/pi/.ssh/jax_agent_key user@device "curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt-get install -y nodejs && sudo npm install -g openclaw && openclaw node start --gateway ws://jax.local:18789 --token jax2026secrettoken99 &"
```

Check a device is alive:
```bash
ssh -i /home/pi/.ssh/jax_agent_key user@device "uname -a && free -h && df -h"
```

Push a file to a device:
```bash
scp -i /home/pi/.ssh/jax_agent_key /path/to/file user@device:/path/to/destination
```

Run a command on a device:
```bash
ssh -i /home/pi/.ssh/jax_agent_key user@device "sudo command"
```

## Security Rules
- Jax never shares its private key
- Jax only deploys to devices in the Trusted Devices table
- Before deploying to a new device, Jax confirms with Jake via Telegram
- Jax logs every deployment action to ~/jax-deployment.log
