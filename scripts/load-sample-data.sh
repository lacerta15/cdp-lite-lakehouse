#!/usr/bin/env bash
# Upload the bundled sample CSV (NYC taxi sample) into MinIO `raw` zone.
set -euo pipefail

DATA_FILE="$(dirname "$0")/../data/nyc_trips_sample.csv"
[[ -f "${DATA_FILE}" ]] || { echo "Missing ${DATA_FILE}"; exit 1; }

docker run --rm --network=cdp-lite-lakehouse_lakehouse-net \
    -v "$(realpath "${DATA_FILE}"):/tmp/nyc_trips_sample.csv:ro" \
    --entrypoint /bin/sh \
    minio/mc:latest \
    -c "
        mc alias set local http://minio:9000 ${MINIO_ROOT_USER:-minio} ${MINIO_ROOT_PASSWORD:-minio123} && \
        mc cp /tmp/nyc_trips_sample.csv local/lakehouse/raw/nyc_trips/nyc_trips_sample.csv && \
        mc ls local/lakehouse/raw/nyc_trips/
    "

echo "[load-sample-data] uploaded to s3a://lakehouse/raw/nyc_trips/"
