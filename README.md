## Kafka Connect with ParadeDB

This repo is a simple example of how to use Kafka Connect with ParadeDB. Because ParadeDB runs on
Postgres, we are able to leverage the JDBC sink connector to write data from Kafka to ParadeDB.

### Example

```bash
# Spin up an instance of ParadeDB, a Kafka broker, and Kafka Connect.
# Note that this may take some time since Kafka Connect needs to pull
# the JDBC sink connector JAR from Confluent Hub.
docker compose up -d --wait

# Create a messages table in ParadeDB and a BM25 index. Create a messages
# topic in Kafka. Create a JDBC sink connector in Kafka Connect to pipe the
# topic to the table.
./setup.sh

# Produce some messages to the messages topic in Kafka.
./producer.sh 1000

# Query the messages table in ParadeDB.
./psql.sh
> select sender, target, count(*) from messages where contents @@@ 'energetic' group by sender, target;

# Clean up.
docker compose down
```
