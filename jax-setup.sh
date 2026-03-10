#!/bin/bash
# Jax Full Setup Script
# Run once on a fresh Raspberry Pi OS 64-bit install
# Usage: curl -s URL | bash   OR   bash jax-setup.sh

# Don't exit on error - log failures and continue
FAILED=()

run() {
  echo "Running: $1"
  eval "$2" || { echo "⚠️  FAILED: $1 (continuing)"; FAILED+=("$1"); }
}

echo "🦞 Jax Full Setup Starting..."
echo "================================"

# ── System update ──────────────────────────────────────────────
echo "[1/10] Updating system..."
sudo apt-get update -qq && sudo apt-get upgrade -y -qq

# ── Essential system tools ─────────────────────────────────────
echo "[2/10] Installing system tools..."
sudo apt-get install -y -qq \
  git curl wget nano vim \
  nmap net-tools iputils-ping \
  htop btop \
  rsync \
  build-essential \
  python3 python3-pip python3-venv \
  ffmpeg \
  mosquitto mosquitto-clients \
  samba samba-common-bin \
  watchdog \
  jq \
  unzip zip \
  screen tmux

# ── Node.js 22 via nvm ────────────────────────────────────────
echo "[3/10] Installing Node.js 22..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
nvm install 22
nvm use 22
nvm alias default 22
# Make node/npm available to sudo
NODE_PATH=$(which node)
NPM_PATH=$(which npm)
sudo ln -sf "$NODE_PATH" /usr/local/bin/node
sudo ln -sf "$NPM_PATH" /usr/local/bin/npm
echo "Node: $(node --version) | npm: $(npm --version)"

# ── Ollama ─────────────────────────────────────────────────────
echo "[4/10] Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl enable ollama
sudo systemctl start ollama
sleep 3
echo "Pulling qwen2.5:1.5b model (this takes a while)..."
ollama pull qwen2.5:1.5b

# ── OpenClaw ───────────────────────────────────────────────────
echo "[5/10] Installing OpenClaw..."
sudo npm install -g openclaw
sudo npm install -g clawhub

# ── Swap on SD card (exFAT SSD doesn't support swap) ──────────
echo "[6/10] Setting up swap..."
if [ ! -f /swapfile ]; then
  sudo fallocate -l 2G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  echo "Swap: 2GB on SD card"
else
  echo "Swap already exists, skipping"
fi

# ── Generate unique gateway token ────────────────────────────
echo "Generating unique gateway token..."
TOKEN=$(openssl rand -hex 24)
sed -i "s/REPLACE_WITH_RANDOM_TOKEN/$TOKEN/" ~/.openclaw/openclaw.json
echo "Gateway token: $TOKEN" >> ~/.jax-secrets
chmod 600 ~/.jax-secrets
echo "Token saved to ~/.jax-secrets"

# ── SSH key setup ──────────────────────────────────────────────
echo "[7/10] Setting up SSH keys..."
mkdir -p ~/.ssh && chmod 700 ~/.ssh
# Generate Jax's own agent key for deploying to other devices
if [ ! -f ~/.ssh/jax_agent_key ]; then
  ssh-keygen -t ed25519 -C "jax-agent" -f ~/.ssh/jax_agent_key -N ""
  echo "Jax agent key generated"
fi

# ── Python packages ────────────────────────────────────────────
echo "[8/10] Installing Python packages..."
pip3 install --break-system-packages \
  requests \
  python-telegram-bot \
  paho-mqtt \
  paramiko \
  psutil \
  schedule \
  python-dotenv

# ── Node.js global packages ────────────────────────────────────
echo "[9/10] Installing Node.js packages..."
sudo npm install -g \
  pm2 \
  nodemon

# ── Docker (sandbox for testing code safely) ──────────────────
echo "[9b/10] Installing Docker..."
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker pi
echo "Docker installed - pi user added to docker group"

# ── Watchdog (prevent SD corruption on unclean shutdown) ───────
echo "[10/10] Configuring watchdog..."
sudo systemctl enable watchdog
sudo systemctl start watchdog

# ── Pi performance tweaks ──────────────────────────────────────
echo "Applying Pi optimisations..."
echo "export NODE_COMPILE_CACHE=/var/tmp/openclaw-compile-cache" >> ~/.bashrc
echo "export OPENCLAW_NO_RESPAWN=1" >> ~/.bashrc
echo "export OLLAMA_API_KEY=ollama-local" >> ~/.bashrc
mkdir -p /var/tmp/openclaw-compile-cache

# ── Samba config (share SSD on network) ────────────────────────
echo "Configuring Samba file share..."
sudo tee -a /etc/samba/smb.conf > /dev/null << 'EOF'

[magic-files]
   path = /media/pi/magic files
   browseable = yes
   read only = yes
   guest ok = yes
   comment = Jax Magic Library
EOF
sudo systemctl restart smbd 2>/dev/null || true

# ── Done ───────────────────────────────────────────────────────
echo ""
echo "================================"
echo "✅ Jax setup complete!"
echo ""
echo "Next steps:"
echo "  1. Push config files from Mac: touch ~/pi-files/.openclaw/openclaw.json"
echo "  2. Start gateway: openclaw gateway --force"
echo "  3. Test: openclaw agent --agent main --message 'hello jax'"
echo ""
echo "Jax agent public key (install on other devices):"
cat ~/.ssh/jax_agent_key.pub
echo "================================"

if [ ${#FAILED[@]} -gt 0 ]; then
  echo "⚠️  Some steps failed:"
  for f in "${FAILED[@]}"; do echo "  - $f"; done
  echo "These can be retried manually."
else
  echo "✅ Everything installed successfully."
fi
