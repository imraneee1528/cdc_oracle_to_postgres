# at first dowload kafka file 
::create user kafka on /home/kafka 

# add host name and others master node 
sudo vi /etc/hosts
master1 127.0.0.1
master2 192.168.19.2

sudo apt install default-jre
:: tar file transfer to kafka directory and extrac that file and rename the folder to kafka 

:: add below  lines in master1 
sudo vi /kafka/config/server.properties


delete.topic.enable = true

log.dirs=/home/kafka/logs

zookeeper.connect=192.168.122.234:2181,192.168.122.29:2181


broker.id=0
broker.rack=RACK1
listeners=PLAINTEXT://192.168.122.234:9092
advertised.listeners=PLAINTEXT://192.168.122.234:9092




:: add below  lines in master 2

sudo vi /kafka/config/server.properties


delete.topic.enable = true

log.dirs=/home/kafka/logs

zookeeper.connect=192.168.122.234:2181,192.168.122.29:2181


broker.id=1
broker.rack=RACK2
listeners=PLAINTEXT://192.168.122.234:9092
advertised.listeners=PLAINTEXT://192.168.122.234:9092




# if use multi node then configure 

zookeeper.connect
hostname1:port1,hostname2:port2.

#advertised.listeners: The hostname and port to be published to clients. If running Kafka on multiple machines, use the externally accessible hostname or IP address.

sudo vi /etc/systemd/system/zookeeper.service



[Unit]
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
User=root
ExecStart=/home/kafka/kafka/bin/zookeeper-server-start.sh /home/kafka/kafka/config/zookeeper.properties
ExecStop=/home/kafka/kafka/bin/zookeeper-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target





sudo vi /etc/systemd/system/kafka.service


[Unit]
Requires=zookeeper.service
After=zookeeper.service

[Service]
Type=simple
User=root
ExecStart=/bin/sh -c '/home/kafka/kafka/bin/kafka-server-start.sh /home/kafka/kafka/config/server.properties > /home/kafka/kafka/kafka.log 2>&1'
ExecStop=/home/kafka/kafka/bin/kafka-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target







sudo systemctl start kafka

sudo systemctl status kafka
sudo systemctl enable kafka


sudo systemctl enable zookeeper
sudo systemctl start zookeeper
sudo systemctl status zookeeper


#For check connection 
#create
bin/kafka-topics.sh --create --topic my-topic --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1


echo "Hello, World" | bin/kafka-console-producer.sh --broker-list localhost:9092 --topic my-topic > /dev/null

bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic my-topic  --from-beginning


#delete topics
bin/kafka-topics.sh --delete --topic my-topic --bootstrap-server localhost:9092

# alter topics
bin/kafka-topics.sh --alter --topic my-topic --bootstrap-server localhost:9092

# list topics 

bin/kafka-topics.sh --list --bootstrap-server localhost:9092
#  --describe 
bin/kafka-topics.sh --describe --bootstrap-server localhost:9092

### some changes likely good 

zookeeper.connection.timeout.ms=3000


log.retention.check.interval.ms=300000

log.retention.hours=72 


offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1


num.recovery.threads.per.data.dir=1
num.partitions=1


[Unit]
Description=Zookeeper Daemon
Documentation=http://zookeeper.apache.org
Requires=network.target
After=network.target

[Service]
Type=forking
WorkingDirectory=/opt/zookeeper
User=root
Group=root
LimitNOFILE=3000
ExecStart=/opt/zookeeper/bin/zkServer.sh start /opt/zookeeper/conf/zoo.cfg
ExecStop=/opt/zookeeper/bin/zkServer.sh stop /opt/zookeeper/conf/zoo.cfg
ExecReload=/opt/zookeeper/bin/zkServer.sh restart /opt/zookeeper/conf/zoo.cfg
TimeoutSec=30
#Restart=on-failure

[Install]
WantedBy=default.target






###
/opt/kafka/bin/kafka-topics.sh --bootstrap-server prodmnpspkafkaserver1:9092 --list topic
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server prodmnpspkafkaserver1:9092 --topic a2p-txn-non-billable-se
/opt/kafka/bin/kafka-topics.sh --bootstrap-server prodmnpspkafkaserver1:9092 --alter --topic a2p-promo-non-billable-ae --partitions 10
/opt/kafka/bin/kafka-configs.sh --bootstrap-server prodmnpspkafkaserver1:9092 --topic a2p-promo-non-billable-ae --alter --add-config retention.ms=21600000
/opt/kafka/bin/kafka-topics.sh --bootstrap-server prodmnpspkafkaserver1:9092 --describe topic | grep a2p-promo-non-billable-ae
 systemctl status kafka-bulk-dipping-non-billable-stream.service 

    
    
    [Unit]
Description=Kafka CDR Consumer
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
Group=root

WorkingDirectory=/opt/mnp-kafka-poller
ExecStart=/opt/kafka-scripts/venv/bin/python3 /opt/mnp-kafka-poller/core/counter.py -s a2p-promo-messaging-billable -b prodmnpspkafkaserver1:9092 -l log-a2p -c counter-promotional-stream -i 5 -p parse_a2p

Restart=on-failure
RestartSec=3

StandardOutput=journal
StandardError=inherit

[Install]
WantedBy=multi-user.target
   

