# CDC ORACLE TO POSTGRES
##   Install oracle 11 or default 
<pre>
  apt install default-jre
</pre>
## Dowload kafka and Oracle Debizium Connector 
<pre>
  https://drive.google.com/file/d/1XFdy0ZX9YJXht9yr6qqNr3q9K99sT9AB/view?usp=sharing
</pre>
<pre>
  https://drive.google.com/file/d/162UWiM_lT05fN3XkL3XdFt1FS5L-uKYV/view?usp=sharing
</pre>
<pre>
  https://drive.google.com/file/d/17Z8jAdK8aFTv0_6_QKWOiIKa3os8vCPs/view?usp=sharing
</pre>
#### For Stand alone no need to zookeper or kafka configuration change
####  ADD This 
<pre>
  vim connect-standalone.properties
  <pre>
    rest.port=8084
    plugin.path=/opt/kafka/libs
  </pre>
</pre>

#### extrac Debizium folder and move to this directory /opt/kafka/libs
#### Also  debezium-connector-oracle-2.7.4.Final.jar and ojdbc8-21.11.0.0.jar  in this directory /opt/kafka/libs
#### ADD configuration in Oracle DB
<pre>
CREATE USER debezium IDENTIFIED BY "Tirzok_123" ;
grant connect, create session, imp_full_database to debezium;
ALTER USER debezium  QUOTA 100M ON USERS;
GRANT UNLIMITED TABLESPACE TO debezium;
</pre>
<pre>
sqlplus / as sysdba
SELECT log_mode FROM v$database;
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
ALTER SYSTEM SET LOG_ARCHIVE_DEST_1='LOCATION=/u01/app/oracle/archivelog';
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
ALTER TABLE DEBEZIUM.EMPLOYEES ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
SELECT log_mode FROM v$database;
</pre>

<pre>
  -- 1. Grant EXECUTE on DBMS_LOGMNR (required for LogMiner operations)
GRANT EXECUTE ON SYS.DBMS_LOGMNR TO debezium;

-- 2. Grant SELECT on V$LOG and V$LOGFILE (used to locate redo/archive logs)
GRANT SELECT ON V_$LOG TO debezium;
GRANT SELECT ON V_$LOGFILE TO debezium;

-- 3. Grant SELECT ANY TRANSACTION (needed to read transaction metadata)
GRANT SELECT ANY TRANSACTION TO debezium;

-- 4. Grant LOGMINING privilege (Oracle 12c+) – critical for LogMiner
GRANT LOGMINING TO debezium;

-- Optional but recommended:
-- 5. Grant access to data pump directory (for internal use)
GRANT READ, WRITE ON DIRECTORY DATA_PUMP_DIR TO debezium;

-- 6. Create or confirm directory object for archivelogs
CREATE OR REPLACE DIRECTORY ARCHIVELOG_DIR AS '/u01/app/oracle/archivelog';
GRANT READ ON DIRECTORY ARCHIVELOG_DIR TO debezium;
</pre>

#### Add this for oracle 

<pre>
curl -i -X POST     -H "Content-Type: application/json"     -d '{
"name":"oracle-src-connector",
"config":{
"connector.class":"io.debezium.connector.oracle.OracleConnector",
"tasks.max":"1",
"database.hostname":"192.168.122.76",
"database.port":"1521",
"database.user":"debezium",
"database.password":"Tirzok_123",
"database.dbname" : "pdbtest",
"table.include.list": "demouser.employees",
"topic.prefix":"server_oracle",
"schema.history.internal.kafka.topic":"schmhistory.core_banking",
"schema.history.internal.kafka.bootstrap.servers":"localhost:9092"
 }
   }'     http://localhost:8083/connectors
  
</pre>
