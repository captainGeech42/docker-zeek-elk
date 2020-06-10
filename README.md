# Docker Compose Zeek + ELK
Final project for CS 312 Linux Sysadmin (Spring 2020) at Oregon State University

## Usage

Make sure to set `max_map_count` properly:
```
sysctl -w vm.max_map_count=262144
echo "vm.max_map_count" >> /etc/sysctl.conf
```

This must be done on the host, not in the Elasticsearch container

Then, start the containers. Be aware that Zeek takes a _long_ time to compile (it's worth it though!)
```
docker-compose build
docker-compose up -d
```

ES will be bound to tcp/9200, and Kibana will be bound to tcp/5601

When you first start the containers, ES will initialize itself in a new volume, and Kibana will store it's configuration information in the same index. The first time you connect to Kibana, you will have to configure an index filter, please set it to `filebeat*` and use the `@timestamp` field for timestamps.

Once everything is running, place a PCAP in `pcaps_to_process/` and then your logs will magically appear in Kibana!