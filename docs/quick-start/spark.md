# Quick Start on Spark

In this section we will setup a mock instance of Bullet to play around with. We will use [Bullet Spark](https://github.com/bullet-db/bullet-spark) to run the backend of Bullet on the [Spark](https://spark.apache.org/) framework. And we will use the [Bullet Kafka PubSub](https://github.com/bullet-db/bullet-kafka).

At the end of this section, you will have:

  * Launched the Bullet backend on Spark
  * Setup the [Web Service](../ws/setup.md)
  * Setup the [UI](../ui/setup.md) to talk to the Web Service

**Prerequisites**

  * You will need to be on an Unix-based system (Mac OS X, Ubuntu ...) with ```curl``` installed
  * You will need [JDK 8](http://www.oracle.com/technetwork/java/javase/downloads/index.html) installed

## Install Script

Simply run:

```bash
curl -sLo- https://raw.githubusercontent.com/bullet-db/bullet-db.github.io/src/examples/install-all-spark.sh | bash
```

This will setup a local Spark and Kafka cluster, a Bullet running on it, the Bullet Web Service and a Bullet UI for you. Once everything has launched, you should be able to go to the Bullet UI running locally at [http://localhost:8800](http://localhost:8800). You can then [**continue this guide from here**](#what-did-we-do).

!!! note "Want to DIY?"
    If you want to manually run all the commands or if the script died while doing something above (might want to perform the [teardown](#teardown) first), you can continue below.

## Manual Installation

#### Step 1: Setup directories and examples

```bash
export BULLET_HOME=$(pwd)/bullet-quickstart
mkdir -p $BULLET_HOME/backend/spark
mkdir -p $BULLET_HOME/pubsub
mkdir -p $BULLET_HOME/service
mkdir -p $BULLET_HOME/ui
cd $BULLET_HOME
curl -LO https://github.com/bullet-db/bullet-db.github.io/releases/download/v0.5.2/examples_artifacts.tar.gz
tar -xzf examples_artifacts.tar.gz
export BULLET_EXAMPLES=$BULLET_HOME/bullet-examples
```

### Setup Kafka

For this instance of Bullet we will use the Kafka PubSub implementation found in [bullet-spark](https://github.com/bullet-db/bullet-spark). So we will first download and run Kafka, and setup a couple Kafka topics.

#### Step 2: Download and Install Kafka

```bash
cd $BULLET_HOME/pubsub
curl -Lo bullet-kafka.jar http://jcenter.bintray.com/com/yahoo/bullet/bullet-kafka/0.3.0/bullet-kafka-0.3.0-fat.jar
curl -LO https://archive.apache.org/dist/kafka/0.11.0.1/kafka_2.12-0.11.0.1.tgz
tar -xzf kafka_2.12-0.11.0.1.tgz
export KAFKA_DIR=$BULLET_HOME/pubsub/kafka_2.12-0.11.0.1
```

#### Step 3: Start Zookeeper

```bash
$KAFKA_DIR/bin/zookeeper-server-start.sh $KAFKA_DIR/config/zookeeper.properties &
```

#### Step 4: Start Kafka

Give Zookeeper ~5-10 seconds to start up, then start Kafka:

```bash
$KAFKA_DIR/bin/kafka-server-start.sh $KAFKA_DIR/config/server.properties &
```

#### Step 5: Create Kafka Topics

The Bullet Kafka PubSub uses two topics. One to send messages from the Web Service to the Backend, and one to send messages from the Backend to the Web Service. So we will create a Kafka topic called "bullet.requests" and another called "bullet.responses".

```bash
$KAFKA_DIR/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic bullet.requests
$KAFKA_DIR/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic bullet.responses
```

### Setup Bullet Backend on Spark

We will run the bullet-spark backend using [Spark 2.2.1](https://spark.apache.org/releases/spark-release-2-2-1.html).

#### Step 6: Install Spark 2.2.1

```bash
export BULLET_SPARK=$BULLET_HOME/backend/spark
cd $BULLET_SPARK
curl -O http://www-eu.apache.org/dist/spark/spark-2.2.1/spark-2.2.1-bin-hadoop2.7.tgz
tar -xzf spark-2.2.1-bin-hadoop2.7.tgz
```

#### Step 7: Setup Bullet-Spark and Example Data Producer

```bash
cp $BULLET_HOME/bullet-examples/backend/spark/* $BULLET_SPARK
curl -Lo bullet-spark.jar http://jcenter.bintray.com/com/yahoo/bullet/bullet-spark/0.1.2/bullet-spark-0.1.2-standalone.jar
```

#### Step 8: Launch the Bullet Spark Backend

Run this multi-line command (new lines are escaped):

```bash
$BULLET_SPARK/spark-2.2.1-bin-hadoop2.7/bin/spark-submit \
    --master local[10]  \
    --class com.yahoo.bullet.spark.BulletSparkStreamingMain \
    --jars $BULLET_HOME/pubsub/bullet-kafka.jar,$BULLET_SPARK/bullet-spark-example.jar \
    $BULLET_SPARK/bullet-spark.jar \
    --bullet-spark-conf=$BULLET_SPARK/bullet_spark_kafka_settings.yaml &> log.txt &

```

The Backend will usually be up and running usually within 5-10 seconds. Once it is running you can get information about the Spark job in the Spark UI, which can be seen in your browser at [http://localhost:4040](http://localhost:4040) by default. The Web Service will now be hooked up through the Kafka PubSub to the Spark backend. To test it you can now run a Bullet query by hitting the Web Service directly:

### Setup Web Service

#### Step 9: Install the Bullet Web Service

```bash
cd $BULLET_HOME/service
curl -Lo bullet-service.jar http://jcenter.bintray.com/com/yahoo/bullet/bullet-service/0.2.1/bullet-service-0.2.1-embedded.jar
cp $BULLET_EXAMPLES/web-service/example_kafka_pubsub_config.yaml $BULLET_HOME/service/
cp $BULLET_EXAMPLES/web-service/example_columns.json $BULLET_HOME/service/
```

#### Step 10: Launch the Web Service

Run this multi-line command (new lines are escaped):

```bash
java -Dloader.path=$BULLET_HOME/pubsub/bullet-kafka.jar -jar bullet-service.jar \
    --bullet.pubsub.config=$BULLET_HOME/service/example_kafka_pubsub_config.yaml \
    --bullet.schema.file=$BULLET_HOME/service/example_columns.json \
    --server.port=9999  \
    --logging.path=. \
    --logging.file=log.txt &> log.txt &
```

#### Step 11: Test the Web Service (optional)

We can check that the Web Service is up and running by getting the example columns through the API:

```bash
curl -s http://localhost:9999/api/bullet/columns
```

```bash
curl -s -H 'Content-Type: text/plain' -X POST -d '{"aggregation": {"size": 1}}' http://localhost:9999/api/bullet/sse-query
```

This query will return a result JSON containing a "records" field containing a single record, and a "meta" field with some meta information.

!!! note "What is this data?"

    This data is randomly generated by the [custom Spark Streaming Receiver](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/spark/src/main/scala/com/yahoo/bullet/spark/examples/receiver/RandomReceiver.scala) that generates toy data to demo Bullet. In practice, your producer would read from an actual data source such as Kafka etc.

You can also check the status of the Web Service by looking at the Web Service log: $BULLET_HOME/service/log.txt

### Setting up the Bullet UI

#### Step 12: Install Node

```bash
cd $BULLET_HOME/ui
curl -s https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash
source ~/.bashrc
nvm install v6.9.4
nvm use v6.9.4
```

#### Step 13: Install the Bullet UI

```bash
curl -LO https://github.com/bullet-db/bullet-ui/releases/download/v0.5.0/bullet-ui-v0.5.0.tar.gz
tar -xzf bullet-ui-v0.5.0.tar.gz
cp $BULLET_EXAMPLES/ui/env-settings.json config/
```

#### Step 14: Launch the UI

```bash
PORT=8800 node express-server.js &
```

Visit [http://localhost:8800](http://localhost:8800) to query your topology with the UI. See [UI usage](../ui/usage.md) for some example queries and interactions using this UI. You see what the Schema means by visiting the Schema section.

!!! note "Running it remotely?"

    If you access the UI from another machine than where your UI is actually running, you will need to edit ```config/env-settings.json```. Since the UI is a client-side app, the machine that your browser is running on will fetch the UI and attempt to use these settings to talk to the Web Service. Since they point to localhost by default, your browser will attempt to connect there and fail. An easy fix is to change ```localhost``` in your env-settings.json to point to the host name where you will hosting the UI. This will be the same as the UI host you use in the browser. You can also do a local port forward on the machine accessing the UI by running: ```ssh -N -L 8800:localhost:8800 -L 9999:localhost:9999 hostname-of-the-quickstart-components 2>&1```.

#### Playing around with the instance:

Check out and follow along with the [UI Usage](../ui/usage.md) page as it shows you some queries you can run using this UI.

## Teardown

When you are done trying out Bullet, you can stop the processes and cleanup using the instructions below.

If you were using the [Install Script](#install-script) or if you don't want to manually bring down everything, you can run:

```bash
curl -sLo- https://raw.githubusercontent.com/bullet-db/bullet-db.github.io/src/examples/install-all-spark.sh | bash -s cleanup
```

If you were performing the steps yourself, you can also manually cleanup **all the components and all the downloads** using:

|                |                                                                                |
| -------------- | ------------------------------------------------------------------------------ |
| UI             | ```pkill -f [e]xpress-server.js```                                             |
| Web Service    | ```pkill -f [e]xample_kafka_pubsub_config.yaml```                              |
| Spark          | ```pkill -f [b]ullet-spark```                                                  |
| Kafka          | ```${KAFKA_DIR}/bin/kafka-server-stop.sh```                                    |
| Zookeeper      | ```${KAFKA_DIR}/bin/zookeeper-server-stop.sh```                                |
| File System    | ```rm -rf $BULLET_HOME /tmp/zookeeper /tmp/kafka-logs/ tmp/spark-checkpoint``` |

Note: This does *not* delete ```$HOME/.nvm```.

## What did we do?

This section will go over the various custom pieces this example plugged into Bullet, so you can better understand what we did.

### Spark Streaming Job

The Spark Streaming application we ran was Bullet plugged in with a custom Receiver in our implementation of the Bullet Spark DataProducer trait. This Receiver and DataProducer are implemented in this [example project](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/spark/) and was already built for you when you [downloaded the examples](#step-1-setup-directories-and-examples). It does not read from any data source and just produces random, structured data. It also produces only up to a maximum number of records in a given period. Both this maximum and the length of a period are configured in the Receiver (at most 100 every 1 second).

```bash
$BULLET_SPARK/spark-2.2.1-bin-hadoop2.7/bin/spark-submit \
    --master local[10]  \
    --class com.yahoo.bullet.spark.BulletSparkStreamingMain \
    --jars $BULLET_HOME/pubsub/bullet-kafka.jar,$BULLET_SPARK/bullet-spark-example.jar \
    $BULLET_SPARK/bullet-spark.jar \
    --bullet-spark-conf=$BULLET_SPARK/bullet_spark_kafka_settings.yaml &> log.txt &

```

We launched the bullet-spark jar (an uber or "fat" jar) containing Bullet Spark and all its dependencies. We added our Pubsub (see below) implementation and our jar containing our custom Receiver to the Spark job's additional jars.

The settings defined by ```--bullet-spark-conf=$BULLET_SPARK/bullet_spark_kafka_settings.yaml``` and the arguments here run all components in the Spark Streaming job.

!!! note "I thought you said hundreds of thousands of records..."

    100 records per second is not Big Data by any stretch of the imagination but this Quick Start is running everything on one machine and is meant to introduce you to what Bullet does. In practice, you would scale and run your components with CPU and memory configurations to accommodate for your data volume and querying needs.


Let's look at the [custom Receiver code](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/spark/src/main/scala/com/yahoo/bullet/spark/examples/receiver/RandomReceiver.scala) that generates the data.

```scala
  private def receive(): Unit = {
    nextIntervalStart = System.currentTimeMillis()
    while (!isStopped) {
      val timeNow = System.currentTimeMillis()
      // Only emit if we are still in the interval and haven't gone over our per period max
      if (timeNow <= nextIntervalStart && generatedThisPeriod < maxPerPeriod) {
        store(generateRecord())
        generatedThisPeriod += 1
      }
      if (timeNow > nextIntervalStart) {
        logger.info("Generated {} tuples out of {}", generatedThisPeriod, maxPerPeriod)
        nextIntervalStart = timeNow + period
        generatedThisPeriod = 0
        periodCount += 1
      }
      // It is courteous to sleep for a short time.
      try {
        Thread.sleep(1)
      } catch {
        case e: InterruptedException => logger.error("Error: ", e)
      }
    }
  }
```

This method above emits the data. This method is wrapped in a thread that is called by the Spark framework. This function only emits at most the given maximum tuples per period.

```scala
  private def makeRandomMap: Map[java.lang.String, java.lang.String] = {
    val randomMap = new HashMap[java.lang.String, java.lang.String](2)
    randomMap.put(RandomReceiver.RANDOM_MAP_KEY_A, RandomReceiver.STRING_POOL(Random.nextInt(RandomReceiver.STRING_POOL.length)))
    randomMap.put(RandomReceiver.RANDOM_MAP_KEY_B, RandomReceiver.STRING_POOL(Random.nextInt(RandomReceiver.STRING_POOL.length)))
    randomMap
  }

  private def generateRecord(): BulletRecord = {
    val record = new SimpleBulletRecord()
    val uuid = UUID.randomUUID().toString
    record.setString(RandomReceiver.STRING, uuid)
    record.setLong(RandomReceiver.LONG, generatedThisPeriod)
    record.setDouble(RandomReceiver.DOUBLE, Random.nextDouble())
    record.setDouble(RandomReceiver.GAUSSIAN, Random.nextGaussian())
    record.setString(RandomReceiver.TYPE, RandomReceiver.STRING_POOL(Random.nextInt(RandomReceiver.STRING_POOL.length)))
    record.setLong(RandomReceiver.DURATION, System.nanoTime() % RandomReceiver.INTEGER_POOL(Random.nextInt(RandomReceiver.INTEGER_POOL.length)))

    // Don't use Scala Map and convert it by asJava when calling setxxxMap method in BulletRecord.
    // It converts Scala Map to scala.collection.convert.Wrappers$MapWrapper which is not serializable in scala 2.11.x (https://issues.scala-lang.org/browse/SI-8911).

    record.setStringMap(RandomReceiver.SUBTYPES_MAP, makeRandomMap);

    val booleanMap = new HashMap[java.lang.String, java.lang.Boolean](4)
    booleanMap.put(uuid.substring(0, 8), Random.nextBoolean())
    booleanMap.put(uuid.substring(9, 13), Random.nextBoolean())
    booleanMap.put(uuid.substring(14, 18), Random.nextBoolean())
    booleanMap.put(uuid.substring(19, 23), Random.nextBoolean())
    record.setBooleanMap(RandomReceiver.BOOLEAN_MAP, booleanMap)


    val statsMap = new HashMap[java.lang.String, java.lang.Long](4)
    statsMap.put(RandomReceiver.PERIOD_COUNT, periodCount)
    statsMap.put(RandomReceiver.RECORD_NUMBER, periodCount * maxPerPeriod + generatedThisPeriod)
    statsMap.put(RandomReceiver.NANO_TIME, System.nanoTime())
    statsMap.put(RandomReceiver.TIMESTAMP, System.nanoTime())
    record.setLongMap(RandomReceiver.STATS_MAP, statsMap)

    record.setListOfStringMap(RandomReceiver.LIST, asList(makeRandomMap, makeRandomMap))
    record
  }
```

This ```generateRecord``` method generates some fields randomly and inserts them into a BulletRecord (simple). Note that the BulletRecord is typed and all data must be inserted with the proper types.


This whole receiver is plugged into an implementation of the Spark DataProducer trait that Bullet Spark requires to plug in your data (as a Spark DStream) into it. You can find this class implemented [here](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/spark/src/main/scala/com/yahoo/bullet/spark/examples/RandomProducer.scala) and reproduced below.

```scala
package com.yahoo.bullet.spark.examples

import com.yahoo.bullet.record.BulletRecord
import com.yahoo.bullet.spark.DataProducer
import com.yahoo.bullet.spark.examples.receiver.RandomReceiver
import com.yahoo.bullet.spark.utils.BulletSparkConfig
import org.apache.spark.streaming.StreamingContext
import org.apache.spark.streaming.dstream.DStream

class RandomProducer extends DataProducer {
  override def getBulletRecordStream(ssc: StreamingContext, config: BulletSparkConfig): DStream[BulletRecord] = {
    // Bullet record input stream.
    val bulletReceiver = new RandomReceiver(config)
    ssc.receiverStream(bulletReceiver).asInstanceOf[DStream[BulletRecord]]
  }
}
```

If you put Bullet on your data, you will need to write a DataProducer (or a full on Spark DAG if your reading is complex), that reads from your data source and emits a DStream of BulletRecords with the fields you wish to be query-able similar to this example.

### PubSub

We used the [Kafka PubSub](../pubsub/kafka.md). We configured the Backend to use this PubSub by adding these settings to the YAML file that we passed to our Spark Streaming job. Notice that we set the context to ```QUERY_PROCESSING``` since this is the Backend.

```yaml
bullet.pubsub.context.name: "QUERY_PROCESSING"
bullet.pubsub.class.name: "com.yahoo.bullet.kafka.KafkaPubSub"
bullet.pubsub.kafka.bootstrap.servers: "localhost:9092"
bullet.pubsub.kafka.request.topic.name: "bullet.requests"
bullet.pubsub.kafka.response.topic.name: "bullet.responses"
```

For the Web Service, we passed in a YAML file that pointed to the same Kafka topics. Notice that we set the context to ```QUERY_SUBMISSION``` since this is the Web Service.

```yaml
bullet.pubsub.context.name: "QUERY_SUBMISSION"
bullet.pubsub.class.name: "com.yahoo.bullet.kafka.KafkaPubSub"
bullet.pubsub.kafka.bootstrap.servers: "localhost:9092"
bullet.pubsub.kafka.request.topic.name: "bullet.requests"
bullet.pubsub.kafka.response.topic.name: "bullet.responses"
```

### Web Service

We launched the Web Service using two custom files - a PubSub configuration YAML file and JSON schema file.

The JSON columns file contains the schema for our data specified in JSON. Since our schema is not going to change, we use the Web Service to serve it from a file. If your schema changes dynamically, you will need to provide your own endpoint to the UI.

The following is a snippet from the [JSON file](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/web-service/example_columns.json). Notice how the types of the fields are specified. Also, if you have generated BulletRecord with Map fields whose keys are known, you can specify them here using ```enumerations```.

```javascript
[
    {
        "name": "probability",
        "type": "DOUBLE",
        "description": "Generated from Random#nextDouble"
    },
    ...
    {
        "name": "stats",
        "type": "MAP",
        "subtype": "LONG",
        "description": "This map contains some numeric information such as the current number of periods etc.",
        "enumerations": [
            ...
            {"name": "nano_time", "description": "The ns time when this record was generated"}
        ]
    },
    {
        "name": "classifiers",
        "type": "LIST",
        "subtype": "MAP",
        "description": "This contains two maps, each with: field_A and field_B whose values are randomly chosen from: foo, bar, baz, qux, quux, norf"
    }
]
```
The contents of the [PubSub configuration file](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/web-service/example_kafka_pubsub_config.yaml) was discussed in the [PubSub section above](#pubsub).

### UI

Finally, we configured the UI with the custom environment specific settings file. We did not add any environments since we only had the one.

```javascript
{
  "default": {
    "queryHost": "http://localhost:9999",
    "queryNamespace": "api/bullet",
    "queryPath": "ws-query",
    "queryStompRequestChannel": "/server/request",
    "queryStompResponseChannel": "/client/response",
    "schemaHost": "http://localhost:9999",
    "schemaNamespace": "api/bullet",
    "helpLinks": [
      {
        "name": "Tutorials",
        "link": "https://bullet-db.github.io/ui/usage"
      }
    ],
    "bugLink": "https://github.com/bullet-db/bullet-ui/issues",
    "modelVersion": 3,
    "migrations": {
      "deletions": "query"
    },
    "defaultValues": {
      "aggregationMaxSize": 1024,
      "rawMaxSize": 500,
      "durationMaxSecs": 86400,
      "distributionNumberOfPoints": 11,
      "distributionQuantilePoints": "0, 0.25, 0.5, 0.75, 0.9, 1",
      "distributionQuantileStart": 0,
      "distributionQuantileEnd": 1,
      "distributionQuantileIncrement": 0.1,
      "windowEmitFrequencyMinSecs": 1,
      "everyForRecordBasedWindow": 1,
      "everyForTimeBasedWindow": 2,
      "sketches": {
        "countDistinctMaxEntries": 16384,
        "groupByMaxEntries": 512,
        "distributionMaxEntries": 1024,
        "distributionMaxNumberOfPoints": 200,
        "topKMaxEntries": 1024,
        "topKErrorType": "No False Negatives"
      },
      "metadataKeyMapping": {
        "querySection": "Query",
        "windowSection": "Window",
        "sketchSection": "Sketch",
        "theta": "Theta",
        "uniquesEstimate": "Uniques Estimate",
        "queryCreationTime": "Receive Time",
        "queryTerminationTime": "Finish Time",
        "estimatedResult": "Was Estimated",
        "standardDeviations": "Standard Deviations",
        "normalizedRankError": "Normalized Rank Error",
        "maximumCountError": "Maximum Count Error",
        "itemsSeen": "Items Seen",
        "minimumValue": "Minimum Value",
        "maximumValue": "Maximum Value",
        "windowNumber": "Number",
        "windowSize": "Size",
        "windowEmitTime": "Emit Time",
        "expectedEmitTime": "Expected Emit Time"
      }
    }
  }
}
```

Since we served our schema through the same Web Service as our queries, both these point to our Web Service. Note that there is no ```schemaPath``` because it must be the constant string ```columns```. If you define a custom endpoint for your schema, you must ensure that it can be obtained by making a GET request to ```schemaHost/schemaNamespace/columns```.
