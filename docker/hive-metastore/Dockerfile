# CDP-Lite Hive Metastore image
# Hive 3.1.3 metastore-only mode (run via `hive --service metastore`)
# backed by PostgreSQL, pre-wired for S3A (MinIO) so it can serve external
# tables on object storage.
#
# NOTE: Apache stopped publishing `hive-standalone-metastore-X.Y.Z-bin.tar.gz`
# after the 3.0.0 line. For 3.1.x we pull the full Hive binary and start the
# metastore service directly. This is the same approach Cloudera uses inside
# the CDP Hive parcel.
#
# Build:  docker build -t cdp-lite-hive-metastore:3.1.3 .
# Run:    see compose service `hive-metastore`

FROM eclipse-temurin:8-jre-jammy

ARG HIVE_VERSION=3.1.3
ARG HADOOP_VERSION=3.3.6
ARG POSTGRES_JDBC_VERSION=42.7.3

ENV HIVE_HOME=/opt/hive \
    HADOOP_HOME=/opt/hadoop \
    PATH=/opt/hive/bin:/opt/hadoop/bin:$PATH \
    HADOOP_CLASSPATH=/opt/hadoop/share/hadoop/tools/lib/*

# Runtime deps
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl wget netcat-openbsd procps gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Hadoop (gives us hadoop-common + S3A connectors + AWS SDK bundle)
RUN wget -q "https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
    && tar -xzf "hadoop-${HADOOP_VERSION}.tar.gz" -C /opt \
    && mv "/opt/hadoop-${HADOOP_VERSION}" "${HADOOP_HOME}" \
    && rm "hadoop-${HADOOP_VERSION}.tar.gz"

# Full Hive distribution (standalone-metastore tarball discontinued for 3.1.x)
RUN wget -q "https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz" \
    && tar -xzf "apache-hive-${HIVE_VERSION}-bin.tar.gz" -C /opt \
    && mv "/opt/apache-hive-${HIVE_VERSION}-bin" "${HIVE_HOME}" \
    && rm "apache-hive-${HIVE_VERSION}-bin.tar.gz"

# Wire in JDBC + S3A jars; resolve the well-known Hive/Hadoop guava conflict
# by replacing Hive's bundled guava-19 with the newer guava that Hadoop 3.3 ships.
RUN wget -q -P "${HIVE_HOME}/lib/" \
        "https://jdbc.postgresql.org/download/postgresql-${POSTGRES_JDBC_VERSION}.jar" \
    && cp ${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-*.jar          ${HIVE_HOME}/lib/ \
    && cp ${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-*.jar ${HIVE_HOME}/lib/ \
    && find ${HIVE_HOME}/lib -name "guava-*.jar" -delete \
    && cp ${HADOOP_HOME}/share/hadoop/common/lib/guava-*.jar              ${HIVE_HOME}/lib/

# Drop privileges
RUN groupadd -r hive && useradd -r -g hive -d /opt/hive -s /bin/bash hive \
    && chown -R hive:hive ${HIVE_HOME} ${HADOOP_HOME}

COPY --chown=hive:hive hive-site.xml.tpl ${HIVE_HOME}/conf/hive-site.xml.tpl
COPY --chown=hive:hive entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER hive
EXPOSE 9083

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=5 \
    CMD nc -z localhost 9083 || exit 1

LABEL org.opencontainers.image.title="cdp-lite-hive-metastore" \
      org.opencontainers.image.description="Apache Hive 3.1.3 Metastore (standalone mode) with S3A + Postgres for CDP-Lite Lakehouse" \
      org.opencontainers.image.source="https://github.com/lacerta15/cdp-lite-lakehouse" \
      org.opencontainers.image.licenses="Apache-2.0"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
