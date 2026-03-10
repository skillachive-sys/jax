# Sandbox Testing Skill

## Purpose
Before running any code on a real device, Jax tests it in an isolated Docker container. The container is disposable — if something goes wrong, it's deleted and nothing real is affected.

## How It Works
1. Jax writes the code it wants to test
2. Spins up a fresh Docker container
3. Runs the code inside it
4. Checks the output and any errors
5. If it works: deploys to the real target
6. If it fails: analyses the error, fixes the code, retries in sandbox
7. Container is destroyed after testing regardless of outcome

## Sandbox Commands

### Spin up a test container
```bash
docker run --rm -it --name jax-sandbox ubuntu:22.04 bash
```

### Run a script in sandbox (non-interactive)
```bash
docker run --rm --name jax-sandbox -v /home/pi/jax-sandbox:/workspace ubuntu:22.04 bash -c "cd /workspace && bash test-script.sh"
```

### Node.js sandbox
```bash
docker run --rm --name jax-sandbox -v /home/pi/jax-sandbox:/workspace node:22 bash -c "cd /workspace && node test.js"
```

### Python sandbox
```bash
docker run --rm --name jax-sandbox -v /home/pi/jax-sandbox:/workspace python:3.11 bash -c "cd /workspace && python test.py"
```

### Kill sandbox if stuck
```bash
docker kill jax-sandbox 2>/dev/null; docker rm jax-sandbox 2>/dev/null
```

## Sandbox Directory
`/home/pi/jax-sandbox/` — Jax writes test files here before running them in the container. This directory is mounted into the container so Jax can pass files in and read output back.

## Rules

1. **Always sandbox first** — any code Jax writes gets tested in sandbox before running on a real device
2. **Never mount sensitive directories** — don't mount `~/.ssh`, `~/.openclaw`, or the magic library SSD into the sandbox
3. **Time limit** — sandbox tests have a 2 minute timeout. If it hasn't finished, kill it and investigate
4. **Log sandbox results** — pass or fail goes into the action log with the output
5. **Clean up** — always destroy the container after testing, never leave containers running

## What the Sandbox Can't Test
- Network discovery (sandbox is isolated)
- GPIO/hardware interaction
- Inter-device SSH
- Anything requiring real credentials

For these, Jax must explain to Jake that it can't sandbox test this specific thing and ask for explicit approval before running it live.
