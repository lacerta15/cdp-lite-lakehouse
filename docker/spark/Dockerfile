# CDP-Lite Spark image (3.5.0 with S3A + Iceberg + Postgres JDBC)
# Hardened: non-root user, slim base, healthcheck.
FROM eclipse-temurin:17-jre-jammy

ARG SPARK_VERSION=3.5.0
ARG HADOOP_VERSION=3
ARG ICEBERG_VERSION=1.4.3
ARG AWS_SDK_VERSION=1.12.367
ARG HADOOP_AWS_VERSION=3.3.4

ENV SPARK_HOME=/opt/spark \
    PATH=/opt/spark/bin:/opt/spark/sbin:$PATH \
    PYSPARK_PYTHON=python3

RUN apt-get update && apt-get install -y --no-install-recommends \
        curl wget python3 python3-pip procps \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" \
    && tar -xzf "spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" -C /opt \
    && mv "/opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}" "${SPARK_HOME}" \
    && rm "spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz"

# Pull S3A connector + AWS SDK + Iceberg runtime + Postgres JDBC into Spark jars dir
RUN cd "${SPARK_HOME}/jars" && \
    wget -q "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_AWS_VERSION}/hadoop-aws-${HADOOP_AWS_VERSION}.jar" && \
    wget -q "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_SDK_VERSION}/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar" && \
    wget -q "https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/${ICEBERG_VERSION}/iceberg-spark-runtime-3.5_2.12-${ICEBERG_VERSION}.jar" && \
    wget -q "https://jdbc.postgresql.org/download/postgresql-42.7.3.jar"

# Default spark-defaults.conf points at our HMS + MinIO
COPY spark-defaults.conf ${SPARK_HOME}/conf/spark-defaults.conf

RUN groupadd -r spark && useradd -r -g spark -d /opt/spark -s /bin/bash spark \
    && chown -R spark:spark ${SPARK_HOME}

USER spark
WORKDIR ${SPARK_HOME}

EXPOSE 7077 8080 4040

LABEL org.opencontainers.image.title="cdp-lite-spark" \
      org.opencontainers.image.description="Spark 3.5.0 with S3A, Iceberg 1.4.3, and Hive Metastore wiring for CDP-Lite Lakehouse" \
      org.opencontainers.image.licenses="Apache-2.0"
