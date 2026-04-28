#!/usr/bin/env bash
# CDP-Lite Superset bootstrap — initializes DB + admin user on first run, then starts the webserver.
set -euo pipefail

echo "[bootstrap] running superset db upgrade"
superset db upgrade

echo "[bootstrap] ensuring admin user exists"
superset fab create-admin \
    --username "${ADMIN_USERNAME:-admin}" \
    --firstname Admin \
    --lastname User \
    --email "${ADMIN_EMAIL:-admin@example.com}" \
    --password "${ADMIN_PASSWORD:-admin}" || true

echo "[bootstrap] running superset init"
superset init

echo "[bootstrap] starting Superset on :8088"
exec /usr/bin/run-server.sh
