# CDP-Lite Superset image — Apache Superset 3.0.1 with Trino + PostgreSQL drivers
FROM apache/superset:3.0.1

USER root

# Add Trino + Postgres SQLAlchemy dialects
RUN pip install --no-cache-dir \
        trino[sqlalchemy]==0.328.0 \
        sqlalchemy-trino==0.5.0 \
        psycopg2-binary==2.9.9 \
        Pillow==10.3.0

COPY superset_config.py /app/pythonpath/superset_config.py
COPY bootstrap.sh /app/bootstrap.sh
RUN chmod +x /app/bootstrap.sh

USER superset

LABEL org.opencontainers.image.title="cdp-lite-superset" \
      org.opencontainers.image.description="Apache Superset 3.0.1 pre-wired for Trino in CDP-Lite Lakehouse" \
      org.opencontainers.image.licenses="Apache-2.0"

ENTRYPOINT ["/app/bootstrap.sh"]
