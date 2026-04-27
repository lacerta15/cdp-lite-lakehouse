-- ============================================================
-- CDP-Lite demo queries (run on Trino UI: http://localhost:8081)
-- Bronze tables are all-VARCHAR (Hive CSV connector limitation).
-- Silver tables are typed Iceberg/Parquet — query directly without CAST.
-- ============================================================

-- 1. BRONZE — vendor volume + average fare (CAST at query time)
SELECT vendor_id,
       COUNT(*)                                       AS trips,
       ROUND(AVG(CAST(fare_amount  AS DOUBLE)), 2)    AS avg_fare,
       ROUND(SUM(CAST(total_amount AS DOUBLE)), 0)    AS total_revenue
FROM   hive.bronze.nyc_trips_raw
GROUP  BY vendor_id
ORDER  BY trips DESC;

-- 2. BRONZE — tip behavior by payment type
SELECT payment_type,
       COUNT(*)                                                  AS trips,
       ROUND(AVG(CAST(tip_amount AS DOUBLE)), 2)                 AS avg_tip,
       ROUND(AVG(CAST(tip_amount AS DOUBLE) * 1.0
                 / NULLIF(CAST(fare_amount AS DOUBLE), 0)), 3)   AS avg_tip_pct
FROM   hive.bronze.nyc_trips_raw
WHERE  CAST(fare_amount AS DOUBLE) > 0
GROUP  BY payment_type
ORDER  BY trips DESC;

-- 3. PROMOTE bronze -> silver as Iceberg (typed columns, ACID, snapshot-aware)
CREATE TABLE IF NOT EXISTS iceberg.silver.nyc_trips
WITH (format = 'PARQUET') AS
SELECT vendor_id,
       CAST(pickup_datetime  AS TIMESTAMP) AS pickup_ts,
       CAST(dropoff_datetime AS TIMESTAMP) AS dropoff_ts,
       CAST(passenger_count  AS INTEGER)   AS passenger_count,
       CAST(trip_distance    AS DOUBLE)    AS trip_distance,
       CAST(fare_amount      AS DOUBLE)    AS fare_amount,
       CAST(tip_amount       AS DOUBLE)    AS tip_amount,
       CAST(total_amount     AS DOUBLE)    AS total_amount,
       payment_type
FROM   hive.bronze.nyc_trips_raw
WHERE  CAST(fare_amount AS DOUBLE) > 0;

-- 4. SILVER — same query as #1 but no CAST needed (data is already typed)
SELECT vendor_id,
       COUNT(*)                       AS trips,
       ROUND(AVG(fare_amount), 2)     AS avg_fare,
       ROUND(SUM(total_amount), 0)    AS total_revenue
FROM   iceberg.silver.nyc_trips
GROUP  BY vendor_id
ORDER  BY trips DESC;

-- 5. SILVER — hourly trip distribution (only possible after typing)
SELECT EXTRACT(HOUR FROM pickup_ts) AS pickup_hour,
       COUNT(*)                     AS trips,
       ROUND(AVG(fare_amount), 2)   AS avg_fare
FROM   iceberg.silver.nyc_trips
GROUP  BY EXTRACT(HOUR FROM pickup_ts)
ORDER  BY pickup_hour;
