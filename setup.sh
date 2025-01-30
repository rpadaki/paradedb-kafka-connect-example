#!/bin/bash

echo "Creating DB table and index..."
docker compose exec -T paradedb \
    psql -h localhost -U postgres <<EOF
drop index if exists search_idx;
drop table if exists messages;

create table messages (
    id serial primary key,
    sender text not null,
    target text not null,
    contents text not null
);

create index search_idx on messages
using bm25 (id, sender, target, contents)
with (key_field='id');
EOF

echo "Creating messages kafka topic..."
docker compose exec kafka-broker \
    kafka-topics --delete \
        --topic messages \
        --bootstrap-server localhost:9092 \
        --if-exists || true
docker compose exec kafka-broker \
    kafka-topics --create \
        --topic messages \
        --bootstrap-server localhost:9092 \
        --partitions 1 \
        --replication-factor 1 \
        --if-not-exists

echo "Creating JDBC sink connector..."
docker compose exec -T kafka-connect \
    curl -sX DELETE http://localhost:8083/connectors/messages-sink || true
docker compose exec -T kafka-connect \
    curl -sX POST \
        -H "Content-Type: application/json" \
        --data @- \
        http://localhost:8083/connectors <<EOF
{
    "name": "messages-sink",
    "config": {
        "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
        "tasks.max": "1",
        "topics": "messages",
        "connection.url": "jdbc:postgresql://paradedb:5432/postgres",
        "connection.user": "postgres",
        "connection.password": "postgres",
        "auto.create": "true",
        "insert.mode": "insert",
        "table.name.format": "messages",
        "fields.whitelist": "sender,target,contents"
    }
}
EOF
