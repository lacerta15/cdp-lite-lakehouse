-- Run from Trino:
--   docker exec -it lakehouse-trino trino
--
-- BRONZE layer: external table over raw CSV in MinIO.
-- IMPORTANT: Trino's Hive CSV connector only supports VARCHAR columns.
-- All typing happens in the SILVER layer where data is rewritten as
-- typed Parquet/Iceberg files. This is the canonical bronze/silver pattern.

CREATE SCHEMA IF NOT EXISTS hive.bronze
WITH (location = 's3a://lakehouse/raw/');

CREATE SCHEMA IF NOT EXISTS iceberg.silver;

CREATE TABLE IF NOT EXISTS hive.bronze.nyc_trips_raw (
    vendor_id        VARCHAR,
    pickup_datetime  VARCHAR,
    dropoff_datetime VARCHAR,
    passenger_count  VARCHAR,
    trip_distance    VARCHAR,
    fare_amount      VARCHAR,
    tip_amount       VARCHAR,
    total_amount     VARCHAR,
    payment_type     VARCHAR
)
WITH (
    external_location = 's3a://lakehouse/raw/nyc_trips/',
    format = 'CSV',
    skip_header_line_count = 1
);

-- Smoke test
SELECT COUNT(*) AS rows_in_bronze FROM hive.bronze.nyc_trips_raw;
