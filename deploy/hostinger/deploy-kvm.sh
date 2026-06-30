#!/usr/bin/env bash
# BSX VOICE — plain KVM/VPS deploy (self-managed Traefik + custom UI build)
# Run as root on a fresh Ubuntu/Debian VPS, e.g. Hostinger KVM.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/bitsparx20-arch/BSX_VOICE/main/deploy/hostinger/deploy-kvm.sh | bash
# Or after cloning:
#   sudo bash deploy/hostinger/deploy-kvm.sh
#
# Optional env overrides:
#   PUBLIC_HOST=voice.example.com TURN_HOST=203.0.113.10 REPO_URL=... bash deploy-kvm.sh

set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/bitsparx20-arch/BSX_VOICE.git}"
INSTALL_DIR="${INSTALL_DIR:-/opt/BSX_VOICE}"
SERVER_IP="${SERVER_IP:-$(curl -fsS --max-time 5 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')}"
PUBLIC_HOST="${PUBLIC_HOST:-${SERVER_IP}.sslip.io}"
TURN_HOST="${TURN_HOST:-$SERVER_IP}"
ACME_EMAIL="${ACME_EMAIL:-admin@example.com}"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash $0"
  exit 1
fi

echo "==> BSX VOICE KVM deploy"
echo "    Server IP:  $SERVER_IP"
echo "    Public URL: https://$PUBLIC_HOST"
echo "    TURN host:  $TURN_HOST"

echo "==> Installing Docker (if missing)..."
if ! command -v docker >/dev/null 2>&1; then
  apt-get update -qq
  apt-get install -y ca-certificates curl git ufw
  curl -fsSL https://get.docker.com | sh
  systemctl enable --now docker
fi

echo "==> Opening firewall ports (Web + WebRTC media)..."
if command -v ufw >/dev/null 2>&1; then
  ufw allow 22/tcp || true
  ufw allow 80/tcp || true
  ufw allow 443/tcp || true
  ufw allow 3478/tcp || true
  ufw allow 3478/udp || true
  ufw allow 5349/tcp || true
  ufw allow 5349/udp || true
  ufw allow 49152:49200/udp || true
  ufw --force enable || true
fi

echo "==> Cloning repository..."
if [[ -d "$INSTALL_DIR/.git" ]]; then
  git -C "$INSTALL_DIR" pull --ff-only
  git -C "$INSTALL_DIR" submodule update --init --recursive
else
  git clone --recurse-submodules "$REPO_URL" "$INSTALL_DIR"
fi

DEPLOY_DIR="$INSTALL_DIR/deploy/hostinger"
cd "$DEPLOY_DIR"

gen_secret() { openssl rand -hex 32; }

if [[ ! -f .env ]]; then
  cp .env.example .env
fi

# Idempotent .env updates
set_env() {
  local key="$1" val="$2"
  if grep -q "^${key}=" .env; then
    sed -i "s|^${key}=.*|${key}=${val}|" .env
  else
    echo "${key}=${val}" >> .env
  fi
}

set_env PUBLIC_HOST "$PUBLIC_HOST"
set_env TURN_HOST "$TURN_HOST"
set_env ACME_EMAIL "$ACME_EMAIL"
set_env TRAEFIK_NETWORK "traefik-proxy"
set_env TRAEFIK_ENTRYPOINT "websecure"
set_env TRAEFIK_CERTRESOLVER "letsencrypt"
set_env ENABLE_TELEMETRY "false"
set_env DOGRAH_VERSION "latest"
set_env REGISTRY "dograhai"

if grep -q 'change-me-to-a-long-random-secret' .env; then
  set_env TURN_SECRET "$(gen_secret)"
  set_env OSS_JWT_SECRET "$(gen_secret)"
  set_env REDIS_PASSWORD "$(gen_secret)"
  set_env MINIO_ROOT_PASSWORD "$(gen_secret)"
  set_env POSTGRES_PASSWORD "$(gen_secret)"
fi

docker network create traefik-proxy 2>/dev/null || true

echo "==> Starting Traefik (TLS + routing)..."
docker compose -f docker-compose.traefik.yaml --env-file .env up -d

echo "==> Building custom BSX VOICE UI and starting stack (this may take several minutes)..."
docker compose \
  -f docker-compose.yaml \
  -f docker-compose.build.yaml \
  --env-file .env \
  up -d --build

echo ""
echo "=============================================="
echo " BSX VOICE is starting."
echo " URL: https://${PUBLIC_HOST}"
echo ""
echo " First boot can take 2-5 minutes (DB init + UI build)."
echo " Check status:  cd ${DEPLOY_DIR} && docker compose --env-file .env ps"
echo " View logs:     cd ${DEPLOY_DIR} && docker compose --env-file .env logs -f ui api"
echo "=============================================="
