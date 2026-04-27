# Demo Walkthrough — CDP-Lite Lakehouse

A 5-minute end-to-end demo: ingest a CSV, catalog it, transform it, query it from two engines, visualize it. This is the same pattern you'd run on a full Cloudera CDP cluster — just shrunk to fit on a laptop.

## Prerequisites

* Docker 24+
* 6 GB RAM available to Docker
* Ports free: `8080, 8081, 8088, 9001, 9090, 9870`

## Step 1 — Bring up the stack

```bash
cp .env.example .env
docker compose up -d
docker compose ps
```

Wait until all services show `healthy`. First boot pulls ~2 GB of images and builds the three custom ones; subsequent boots are seconds.

## Step 2 — Initialize MinIO + load sample data

```bash
chmod +x scripts/*.sh
./scripts/init-minio.sh        # creates buckets: lakehouse/{raw,curated,warehouse,iceberg}
./scripts/load-sample-data.sh  # uploads data/nyc_trips_sample.csv -> raw/nyc_trips/
```

Verify in the MinIO Console: <http://localhost:9001> → bucket `lakehouse` → folder `raw/nyc_trips/`.

## Step 3 — Register tables in Hive Metastore (via Trino)

```bash
docker exec -it lakehouse-trino trino
```

Inside the Trino CLI, paste the contents of `scripts/register-tables.sql` or run:

```sql
CREATE SCHEMA IF NOT EXISTS hive.bronze WITH (location = 's3a://lakehouse/raw/');
CREATE TABLE IF NOT EXISTS hive.bronze.nyc_trips_raw (...) WITH (
    external_location = 's3a://lakehouse/raw/nyc_trips/',
    format = 'CSV',
    skip_header_line_count = 1
);
SELECT COUNT(*) FROM hive.bronze.nyc_trips_raw;
```

You now have a queryable table backed by an object-storage CSV — the same pattern Cloudera Data Warehouse uses against Ozone or S3.

## Step 4 — Promote raw → curated as Iceberg

Still in the Trino CLI:

```sql
CREATE SCHEMA IF NOT EXISTS iceberg.silver;

CREATE TABLE iceberg.silver.nyc_trips
WITH (format = 'PARQUET') AS
SELECT vendor_id,
       CAST(pickup_datetime AS TIMESTAMP) AS pickup_ts,
       trip_distance, fare_amount, tip_amount, payment_type
FROM   hive.bronze.nyc_trips_raw
WHERE  fare_amount > 0;
```

The Iceberg table lives at `s3a://lakehouse/iceberg/silver/nyc_trips/` and tracks its own metadata + snapshots — open `lakehouse/iceberg/silver/nyc_trips/metadata/` in MinIO Console to see them.

## Step 5 — Query from Spark too

```bash
docker exec -it lakehouse-spark-master spark-sql
```

```sql
USE iceberg.silver;
SELECT vendor_id, COUNT(*) AS trips, AVG(fare_amount) AS avg_fare
FROM   nyc_trips
GROUP  BY vendor_id;
```

Same metastore, same data files, two compute engines — that's the lakehouse promise.

## Step 6 — Visualize in Superset

1. Open <http://localhost:8088> → log in (`admin` / `admin`)
2. **Settings → Database Connections → + Database**
   * Engine: **Trino**
   * URL: `trino://admin@trino:8080/iceberg`
3. **SQL Lab → SQL Editor** → run any query against `silver.nyc_trips`
4. **Save** → **+ Chart** → pick e.g. *Bar Chart*, dimension `vendor_id`, metric `COUNT(*)`
5. Add to a new dashboard called **NYC Trips Overview**

Screenshot this dashboard for your LinkedIn post.

## Step 7 — Tear down

```bash
docker compose down                  # stop, keep volumes
docker compose down -v               # nuke everything including data
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| `hive-metastore` keeps restarting | Postgres not ready — `docker compose logs postgres` and re-run `docker compose up -d hive-metastore`. |
| Trino can't see schema | Restart Trino after creating the schema, or run `CALL system.flush_metadata_cache();`. |
| MinIO connection refused | Check the `MINIO_ROOT_USER/PASSWORD` env in `.env` matches what's in `spark-defaults.conf` and `hive.properties`. |
| OOM kills | Reduce Spark worker memory in `docker-compose.yml` or close other apps. |
