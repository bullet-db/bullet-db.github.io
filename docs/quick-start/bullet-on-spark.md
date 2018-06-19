# Quick Start - Bullet on Spark

In this section we will setup a mock instance of Bullet to play around with. We will use [bullet-spark](https://github.com/bullet-db/bullet-spark) to run the backend of Bullet on the [Spark](https://spark.apache.org/) framework. And we will use the [Bullet Kafka PubSub](https://github.com/bullet-db/bullet-kafka).

At the end of this section, you will have:

  * Launched the Bullet backend on spark
  * Setup the [Web Service](ws/setup.md)
  * Setup the [UI](ui/setup.md) to talk to the web service

**Prerequisites**

  * You will need to be on an Unix-based system (Mac OS X, Ubuntu ...) with ```curl``` installed
  * You will need [JDK 8](http://www.oracle.com/technetwork/java/javase/downloads/index.html) installed

## To Install and Launch Bullet Locally:

### Setup Kafka

For this instance of Bullet we will use the kafka PubSub implementation found in [bullet-spark](https://github.com/bullet-db/bullet-spark). So we will first download and run Kafka, and setup a couple Kafka topics.

#### Step 1: Setup directories and examples

```bash
export BULLET_HOME=$(pwd)/bullet-quickstart
mkdir -p $BULLET_HOME/backend/spark
mkdir -p $BULLET_HOME/pubsub
mkdir -p $BULLET_HOME/service
mkdir -p $BULLET_HOME/ui
cd $BULLET_HOME
curl -LO https://github.com/bullet-db/bullet-db.github.io/releases/download/v0.5.0/examples_artifacts.tar.gz
tar -xzf examples_artifacts.tar.gz
export BULLET_EXAMPLES=$BULLET_HOME/bullet-examples
```

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

Give Zookeeper a ~5-10 seconds to start up, then start Kafka:

```bash
$KAFKA_DIR/bin/kafka-server-start.sh $KAFKA_DIR/config/server.properties &
```

#### Step 5: Create Kafka Topics

The Bullet Kafka PubSub uses two kafka topics. One to send messages from the web service to the backend, and one to send messages from the backend to the web service. So we will create a kafka topic called "bullet.requests" and another called "bullet.responses".

```bash
$KAFKA_DIR/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic bullet.requests
$KAFKA_DIR/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic bullet.responses
```

### Setup Web Service

#### Step 6: Install the Bullet Web Service

```bash
cd $BULLET_HOME/service
curl -Lo bullet-service.jar http://jcenter.bintray.com/com/yahoo/bullet/bullet-service/0.2.1/bullet-service-0.2.1-embedded.jar
cp $BULLET_EXAMPLES/web-service/example_kafka_pubsub_config.yaml $BULLET_HOME/service/
cp $BULLET_EXAMPLES/web-service/example_columns.json $BULLET_HOME/service/
```

#### Step 7: Launch the Web Service

**Note:** This is a single command (new-lines are escaped) - run it in a single bash command:

```bash
java -Dloader.path=$BULLET_HOME/pubsub/bullet-kafka.jar -jar bullet-service.jar \
    --bullet.pubsub.config=$BULLET_HOME/service/example_kafka_pubsub_config.yaml \
    --bullet.schema.file=$BULLET_HOME/service/example_columns.json \
    --server.port=9999  \
    --logging.path=. \
    --logging.file=log.txt &> log.txt &
```

#### Step 8: Test the Web Service (optional)

We can check that the Web Service is up and running by getting the example columns through the API:

```bash
curl -s http://localhost:9999/api/bullet/columns
```

You can also check the status of the Web Service by looking at the Web Service log: $BULLET_HOME/service/log.txt

### Setup Bullet Backend on Spark

We will run the bullet-spark backend using [Spark 2.2.1](https://spark.apache.org/releases/spark-release-2-2-1.html).

#### Step 9: Install Spark 2.2.1

```bash
export BULLET_SPARK=$BULLET_HOME/backend/spark
cd $BULLET_SPARK
curl -O http://www-eu.apache.org/dist/spark/spark-2.2.1/spark-2.2.1-bin-hadoop2.7.tgz
tar -xzf spark-2.2.1-bin-hadoop2.7.tgz 
```

#### Step 10: Setup Bullet-Spark and Example Data Producer

```bash
cp $BULLET_HOME/bullet-examples/backend/spark/* $BULLET_SPARK
curl -Lo bullet-spark.jar http://jcenter.bintray.com/com/yahoo/bullet/bullet-spark/0.1.1/bullet-spark-0.1.1-standalone.jar
```

#### Step 11: Launch the Bullet Spark Backend

**Note:** This is a single command (new-lines are escaped) - run it in a single bash command:

```bash
$BULLET_SPARK/spark-2.2.1-bin-hadoop2.7/bin/spark-submit \
    --master local[10]  \
    --class com.yahoo.bullet.spark.BulletSparkStreamingMain \
    --driver-class-path $BULLET_SPARK/bullet-spark.jar:$BULLET_HOME/pubsub/bullet-kafka.jar:$BULLET_SPARK/bullet-spark-example.jar \
    $BULLET_SPARK/bullet-spark.jar \
    --bullet-spark-conf=$BULLET_SPARK/bullet_spark_kafka_settings.yaml &> log.txt &

```

The backend will usually be up and running usually within 5-10 seconds. Once it is running you can get information about the Spark job in the Spark UI, which can be seen in your browser at **http://localhost:4040** by default. The Web Service will now be hooked up through the Kafka PubSub to the Spark backend.
To test it you can now run a Bullet query by hitting the web service directly:

```bash
curl -s -H 'Content-Type: text/plain' -X POST -d '{"aggregation": {"size": 1}}' http://localhost:9999/api/bullet/sse-query
```

This query will return a result JSON containing a "records" field containing a single record, and a "meta" field with some meta information. 

!!! note "What is this data?"

    This data is randomly generated by the [custom data producer](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/spark/src/main/scala/com/yahoo/bullet/spark/examples/receiver/RandomReceiver.scala) that was created for the sole purpose of generating toy data to demo Bullet. In practice, your spout would read from an actual data source such as Kafka.

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

Visit [http://localhost:8800](http://localhost:8800) to query your topology with the UI. See [UI usage](ui/usage.md) for some example queries and interactions using this UI. You see what the Schema means by visiting the Schema section.

!!! note "Running it remotely?"

    If you access the UI from another machine than where your UI is actually running, you will need to edit ```config/env-settings.json```. Since the UI is a client-side app, the machine that your browser is running on will fetch the UI and attempt to use these settings to talk to the Web Service. Since they point to localhost by default, your browser will attempt to connect there and fail. An easy fix is to change ```localhost``` in your env-settings.json to point to the host name where you will hosting the UI. This will be the same as the UI host you use in the browser. You can also do a local port forward on the machine accessing the UI by running:
    ```ssh -N -L 8800:localhost:8800 -L 9999:localhost:9999 hostname-of-the-quickstart-components 2>&1```

##  Congratulations!! Bullet is all setup!

#### Playing around with the instance:

Check out and follow along with the [UI Usage](ui/usage.md) page as it shows you some queries you can run using this UI.

## Teardown

When you are done trying out Bullet, you can stop the processes and cleanup all the downloads using:

|                |                                                                  |
| -------------- | ---------------------------------------------------------------- |
| UI             | ```pkill -f [e]xpress-server.js```                               |
| Web Service    | ```pkill -f [e]xample_kafka_pubsub_config.yaml```                |
| Spark          | ```pkill -f [b]ullet-spark```                                    |
| Kafka          | ```${KAFKA_DIR}/bin/kafka-server-stop.sh```                      |
| Zookeeper      | ```${KAFKA_DIR}/bin/zookeeper-server-stop.sh```                  |
| File System    | ```rm -rf $BULLET_HOME```                                        |

Note: This does *not* delete ```$HOME/.nvm```.

