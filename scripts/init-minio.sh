#!/usr/bin/env bash
# Create the lakehouse buckets in MinIO and lay out the medallion zones.
# Idempotent — safe to re-run.
set -euo pipefail

MC_ALIAS="local"
MC_HOST="http://localhost:9090"   # remember: host port 9090 maps to MinIO 9000
MC_USER="${MINIO_ROOT_USER:-minio}"
MC_PASS="${MINIO_ROOT_PASSWORD:-minio123}"

# Use the mc CLI from a throwaway container so we don't require local install
docker run --rm --network=cdp-lite-lakehouse_lakehouse-net \
    --entrypoint /bin/sh \
    minio/mc:latest \
    -c "
        mc alias set ${MC_ALIAS} http://minio:9000 ${MC_USER} ${MC_PASS} && \
        mc mb -p ${MC_ALIAS}/lakehouse && \
        mc mb -p ${MC_ALIAS}/lakehouse/raw && \
        mc mb -p ${MC_ALIAS}/lakehouse/curated && \
        mc mb -p ${MC_ALIAS}/lakehouse/warehouse && \
        mc mb -p ${MC_ALIAS}/lakehouse/iceberg && \
        mc anonymous set download ${MC_ALIAS}/lakehouse/raw && \
        mc ls ${MC_ALIAS}/lakehouse
    "

echo "[init-minio] buckets ready at ${MC_HOST}"
