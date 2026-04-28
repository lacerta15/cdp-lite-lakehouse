<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Hive 3.1.3 metastore-mode site config template.
  Placeholders are substituted at container start by entrypoint.sh
  using `envsubst` against the running environment.
-->
<configuration>

  <!-- ===================== JDBC backend ===================== -->
  <property>
    <name>javax.jdo.option.ConnectionURL</name>
    <value>jdbc:postgresql://${HIVE_METASTORE_DB_HOSTNAME}:5432/${HIVE_METASTORE_DB_NAME}</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionDriverName</name>
    <value>org.postgresql.Driver</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionUserName</name>
    <value>${HIVE_METASTORE_DB_USER}</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionPassword</name>
    <value>${HIVE_METASTORE_DB_PASS}</value>
  </property>

  <!-- ===================== Metastore service ===================== -->
  <property>
    <name>hive.metastore.warehouse.dir</name>
    <value>s3a://lakehouse/warehouse/</value>
  </property>
  <property>
    <name>hive.metastore.uris</name>
    <value>thrift://0.0.0.0:9083</value>
  </property>
  <property>
    <name>hive.metastore.event.db.notification.api.auth</name>
    <value>false</value>
  </property>
  <property>
    <name>hive.metastore.schema.verification</name>
    <value>false</value>
  </property>
  <property>
    <name>datanucleus.autoCreateSchema</name>
    <value>false</value>
  </property>

  <!-- ===================== S3A connector (MinIO) ===================== -->
  <property>
    <name>fs.s3a.endpoint</name>
    <value>${S3_ENDPOINT}</value>
  </property>
  <property>
    <name>fs.s3a.access.key</name>
    <value>${S3_ACCESS_KEY}</value>
  </property>
  <property>
    <name>fs.s3a.secret.key</name>
    <value>${S3_SECRET_KEY}</value>
  </property>
  <property>
    <name>fs.s3a.path.style.access</name>
    <value>true</value>
  </property>
  <property>
    <name>fs.s3a.connection.ssl.enabled</name>
    <value>false</value>
  </property>
  <property>
    <name>fs.s3a.impl</name>
    <value>org.apache.hadoop.fs.s3a.S3AFileSystem</value>
  </property>

</configuration>
