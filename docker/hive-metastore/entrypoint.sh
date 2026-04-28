#!/usr/bin/env bash
# CDP-Lite Hive Metastore entrypoint
# 1. Substitute env vars into hive-site.xml
# 2. Wait for Postgres to accept connections
# 3. Initialize schema if first run (idempotent)
# 4. Start Hive Metastore via `hive --service metastore` on :9083
set -euo pipefail

CONF_TPL="${HIVE_HOME}/conf/hive-site.xml.tpl"
CONF_OUT="${HIVE_HOME}/conf/hive-site.xml"

echo "[entrypoint] rendering hive-site.xml from template"
envsubst < "${CONF_TPL}" > "${CONF_OUT}"

echo "[entrypoint] waiting for Postgres @ ${HIVE_METASTORE_DB_HOSTNAME}:5432"
until nc -z "${HIVE_METASTORE_DB_HOSTNAME}" 5432; do
    sleep 2
done

# schematool prints the current version; non-zero return = no schema yet.
if ! "${HIVE_HOME}/bin/schematool" -dbType postgres -info >/dev/null 2>&1; then
    echo "[entrypoint] initializing Hive Metastore schema (first run)"
    "${HIVE_HOME}/bin/schematool" -initSchema -dbType postgres
else
    echo "[entrypoint] Hive Metastore schema already present — skipping init"
fi

echo "[entrypoint] starting Hive Metastore service on :9083"
exec "${HIVE_HOME}/bin/hive" --service metastore
