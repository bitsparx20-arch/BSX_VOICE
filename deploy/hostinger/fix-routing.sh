#!/usr/bin/env bash
# Fix Traefik 404 after deploy — run on the VPS as root.
set -euo pipefail

cd /opt/BSX_VOICE/deploy/hostinger

echo "==> Current PUBLIC_HOST:"
grep '^PUBLIC_HOST=' .env || true

echo "==> Patch Traefik image (v3.6+ required for Docker 29 API)..."
sed -i 's|image: traefik:v3\.[0-9]*|image: traefik:v3.6|' docker-compose.traefik.yaml

echo "==> Patch Traefik docker network provider..."
if ! grep -q 'providers.docker.network' docker-compose.traefik.yaml; then
  sed -i '/providers.docker.exposedbydefault=false/a\      - --providers.docker.network=traefik-proxy' docker-compose.traefik.yaml
fi

echo "==> Fix ACME email (invalid @sslip.io emails can break cert issuance)..."
sed -i 's|^ACME_EMAIL=.*|ACME_EMAIL=admin@example.com|' .env

echo "==> Restart Traefik..."
docker compose -f docker-compose.traefik.yaml --env-file .env up -d --force-recreate

echo "==> Recreate app containers (refresh Traefik labels)..."
docker compose \
  -f docker-compose.yaml \
  -f docker-compose.build.yaml \
  --env-file .env \
  up -d --force-recreate

echo "==> Waiting 30s for Let's Encrypt..."
sleep 30

echo "==> Traefik logs (ACME / errors):"
docker logs traefik 2>&1 | tail -30

echo ""
echo "==> UI router label on container:"
docker inspect hostinger-ui-1 --format '{{ index .Config.Labels "traefik.http.routers.dograh-ui.rule" }}' 2>/dev/null || echo "(ui container not found)"

echo ""
echo "==> Test from server:"
curl -skI -H "Host: $(grep '^PUBLIC_HOST=' .env | cut -d= -f2)" https://127.0.0.1/ | head -5

echo ""
echo "Open: https://$(grep '^PUBLIC_HOST=' .env | cut -d= -f2)"
