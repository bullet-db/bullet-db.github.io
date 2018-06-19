# Quick Start

This section gets you running a mock instance of Bullet to play around with. The instance will run using Bullet on Spark and use the REST pubsub available as part of bullet-core. Since we do not have an actual data source, we will produce some fake data and convert it into [Bullet Records](backend/ingestion.md) using [some simple custom Spark code](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/spark/src/main/scala/com/yahoo/bullet/spark/examples/receiver/RandomReceiver.scala). If you want to use Bullet for your data, you will need to do read and convert your data to Bullet Records in a similar manner.

At the end of this section, you will have:

  * Launched the Bullet backend on spark
  * Setup the [Web Service](ws/setup.md) with it's built-in REST pubsub enabled
  * Setup the [UI](ui/setup.md) talking to the Web Service using [bullet-ui-0.4.0](https://github.com/yahoo/bullet-ui/releases/tag/v0.4.0)

**Prerequisites**

  * You will need to be on an Unix-based system (Mac OS X, Ubuntu ...) with ```curl``` installed
  * You will need [JDK 8](http://www.oracle.com/technetwork/java/javase/downloads/index.html) installed

## Install Script

Coming soon - a one-liner to start Bullet.

## Manual Installation

### Setup the Bullet Web Service and REST Pub-Sub

Before we launch the Bullet Spark backend, we first need to setup the Bullet Web Service and PubSub layer. The bullet-core repo provides a [pubsub.rest](https://github.com/bullet-db/bullet-core/tree/master/src/main/java/com/yahoo/bullet/pubsub/rest) package which is a simple implementation of the PubSub layer using REST endpoints. The bullet web service can be configured to use this built-in REST PubSub to provide the additional REST endpoints needed to serve as a PubSub layer as well as the web service.

#### Step 1: Setup directories and examples

```bash
export BULLET_HOME=$(pwd)/bullet-quickstart
mkdir -p $BULLET_HOME/backend/spark
mkdir -p $BULLET_HOME/service
mkdir -p $BULLET_HOME/ui
cd $BULLET_HOME
DO THE THING to download the compressed folder - used to be: curl -LO https://github.com/yahoo/bullet-docs/releases/download/v0.4.0/examples_artifacts.tar.gz - now:  cp ~/bullet/bullet-db.github.io/examples/examples_artifacts.tar.gz .
tar -xzf examples_artifacts.tar.gz
export BULLET_EXAMPLES=$BULLET_HOME/bullet-examples
```

#### Step 2: Install the Bullet Web Service

```bash
cd $BULLET_HOME/service
curl -Lo bullet-service.jar http://jcenter.bintray.com/com/yahoo/bullet/bullet-service/0.2.1/bullet-service-0.2.1-embedded.jar
cp $BULLET_EXAMPLES/web-service/example_rest_pubsub_config.yaml $BULLET_HOME/service/
cp $BULLET_EXAMPLES/web-service/example_columns.json $BULLET_HOME/service/
```

#### Step 3: Launch the Web Service

```bash
cd $BULLET_HOME/service
java -jar bullet-service.jar --bullet.pubsub.config=$BULLET_HOME/service/example_rest_pubsub_config.yaml --bullet.schema.file=$BULLET_HOME/service/example_columns.json --server.port=9999 --bullet.endpoint.http=/query --bullet.pubsub.builtin.rest.enabled=true  --logging.path=. --logging.file=log.txt &> log.txt &
```

The Web Service usually takes ~10-15 seconds to start. 

You can check the status of the Web Service by looking at the Web Service log:

```bash
cat $BULLET_HOME/service/log.txt
```

The log should contain a message that reads something like `Started Application in X seconds` (usually the last line of the file if the web service has been run recently).

#### Step 4: Test the Web Service (optional)

We can check that the Web Service is up and running by getting the example columns through the API:

```bash
curl -s http://localhost:9999/api/bullet/columns
```

#### Step 5: Test the PubSub Layer (optional)

To ensure that the Web Service has been configured to expose the necessary PubSub REST endpoints, we can "write" a fake-query to the PubSub, and then read it back by hand. Since there is currently no backend running, any queries written to the PubSub will simply be stored there until we read it manually.

Write a fake empty query to the query endpoint:

```bash
curl -s -H 'Content-Type: application/json' -X POST -d '{}' http://localhost:9999/api/bullet/pubsub/query
```

Receiving no error response should indicate that the fake query was written to the pubsub. Then read a query from this same endpoint:

```bash
curl http://localhost:9999/api/bullet/pubsub/query
```

This should print `'{}'` to the screen, indicating we have successfully written and then read a fake empty query from the PubSub layer. Subsequent reads from this endpoint will return nothing because no more queries have been written to the PubSub endpoint.


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
curl -Lo bullet-spark.jar http://jcenter.bintray.com/com/yahoo/bullet/bullet-spark/0.1.1/bullet-spark-0.1.1-standalone.jar
```

#### Step 8: Launch the Bullet Spark Backend

**Note:** This is a single command (new-lines are escaped) - run it in a single bash command:

```bash
$BULLET_SPARK/spark-2.2.1-bin-hadoop2.7/bin/spark-submit \
    --master local[10]  \
    --class com.yahoo.bullet.spark.BulletSparkStreamingMain \
    --driver-class-path $BULLET_SPARK/bullet-spark.jar:$BULLET_HOME/pubsub/bullet-kafka.jar:$BULLET_SPARK/bullet-spark-example.jar \
    $BULLET_SPARK/bullet-spark.jar \
    --bullet-spark-conf=$BULLET_SPARK/bullet_spark_rest_settings.yaml &> log.txt &

```

The backend will usually be up and running within 5-10 seconds. The Web Service will now be hooked up through the REST PubSub to the Spark backend. You can now run a Bullet query by hitting the web service directly:

```bash
curl -s -H 'Content-Type: text/plain' -X POST -d '{"aggregation": {"size": 1}}' http://localhost:9999/api/bullet/http-query
```

This query will return a result JSON containing a "records" field containing a single record, and a "meta" field with some meta information. 

!!! note "What is this data?"

    This data is randomly generated by the [custom data producer](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/spark/src/main/scala/com/yahoo/bullet/spark/examples/receiver/RandomReceiver.scala) that was created for the sole purpose of generating toy data to demo Bullet. In practice, your spout would read from an actual data source such as Kafka.









### Setting up the Bullet UI

#### Step 9: Install Node

```bash
curl -s https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash
source ~/.bashrc
nvm install v6.9.4
nvm use v6.9.4
```

#### Step 10: Install the Bullet UI

```bash
cd $BULLET_HOME/ui
curl -LO https://github.com/yahoo/bullet-ui/releases/download/v0.4.0/bullet-ui-v0.4.0.tar.gz
tar -xzf bullet-ui-v0.4.0.tar.gz
cp $BULLET_EXAMPLES/ui/env-settings.json config/
```

#### Step 11: Launch the UI

```bash
PORT=8800 node express-server.js &
```

Visit [http://localhost:8800](http://localhost:8800) to query your topology with the UI. See [UI usage](ui/usage.md) for some example queries and interactions using this UI. You see what the Schema means by visiting the Schema section.

!!! note "Running it remotely?"

    If you access the UI from another machine than where your UI is actually running, you will need to edit ```config/env-settings.json```. Since the UI is a client-side app, the machine that your browser is running on will fetch the UI and attempt to use these settings to talk to the Web Service. Since they point to localhost by default, your browser will attempt to connect there and fail. An easy fix is to change ```localhost``` in your env-settings.json to point to the host name where you will hosting the UI. This will be the same as the UI host you use in the browser. You can also do a local port forward on the machine accessing the UI by running:
    ```ssh -N -L 8800:localhost:8800 -L 9999:localhost:9999 hostname-of-the-quickstart-components 2>&1```

##  Playing around with the instance

Check out and follow along with the [UI Usage](ui/usage.md) page as it shows you some queries you can run using this UI.

## Teardown

If you were using the [Install Script](#install-script) or if you don't want to manually bring down everything, you can run:

```bash
curl -sLo- https://raw.githubusercontent.com/yahoo/bullet-docs/v0.4.0/examples/install-all.sh | bash -s cleanup
```

If you were performing the steps yourself, you can also manually cleanup **all the components and all the downloads** using:

|                |                                                                  |
| -------------- | ---------------------------------------------------------------- |
| UI             | ```pkill -f [e]xpress-server.js```                               |
| Web Service    | ```pkill -f [e]xample_drpc_pubsub_config.yaml```                      |
| Spark          | ```pkill -f [b]ullet-spark```                                    |
| File System    | ```rm -rf $BULLET_HOME /tmp/dev-storm-zookeeper /tmp/jetty-*```  |

This does *not* delete ```$HOME/.nvm``` and some extra lines nvm may have added to your ```$HOME/{.profile, .bash_profile, .zshrc, .bashrc}```.

## What did we do?

This section will go over the various custom pieces this example plugged into Bullet, so you can better understand what we did.

### Storm topology

The topology was the Bullet topology plugged in with a custom spout. This spout is implemented in this [example project](https://github.com/yahoo/bullet-docs/blob/master/examples/storm/) and was already built for you when you [downloaded the examples](#step-1-setup-directories-and-examples). It does not read from any data source and just produces random, structured data. It also produces only up to a maximum number of records in a given period. Both this maximum and the length of a period are configurable. If you examine $BULLET_HOME/backend/storm/launch.sh, you'll see the following:

```bash
storm jar bullet-storm-example-1.0-SNAPSHOT-jar-with-dependencies.jar \
          com.yahoo.bullet.Topology \
          --bullet-conf bullet_settings.yaml \
          --bullet-spout com.yahoo.bullet.storm.examples.RandomSpout \
          --bullet-spout-parallelism 1 \
          ...
          --bullet-spout-arg 20 \
          --bullet-spout-arg 101 \
          ...
```

This command launches the jar (an uber or "fat" jar) containing the custom spout code and all dependencies you copied in Step 5. We pass the name of your spout class with ```--bullet-spout com.yahoo.bullet.storm.examples.RandomSpout``` to the Bullet main class ```com.yahoo.bullet.Topology``` with two arguments ```--bullet-spout-arg 20``` and ```--bullet-spout-arg 101```. The first argument tells the Spout to generate at most 20 tuples (records) in a period and the second argument says a period is 101 ms long.

The settings defined by ```--bullet-conf bullet_settings.yaml``` and the arguments here run all components in the topology with a parallelism of 1. So there will be one spout that is producing ~200 rps.

!!! note "I thought you said hundreds of thousands of records..."

    200 records is not Big Data by any stretch of the imagination but this Quick Start is running everything on one machine and is meant to introduce you to what Bullet does. In practice, you would scale and run your components with CPU and memory configurations to accommodate for your data volume and querying needs.


Let's look at the [custom spout code](https://github.com/yahoo/bullet-docs/blob/master/examples/storm/src/main/java/com/yahoo/bullet/storm/examples/RandomSpout.java) that generates the data.

```java
    @Override
    public void nextTuple() {
        long timeNow = System.nanoTime();
        // Only emit if we are still in the interval and haven't gone over our per period max
        if (timeNow <= nextIntervalStart && generatedThisPeriod < maxPerPeriod) {
            outputCollector.emit(new Values(generateRecord()), DUMMY_ID);
            generatedThisPeriod++;
        }
        if (timeNow > nextIntervalStart) {
            log.info("Generated {} tuples out of {}", generatedThisPeriod, maxPerPeriod);
            nextIntervalStart = timeNow + period;
            generatedThisPeriod = 0;
            periodCount++;
        }
        // It is courteous to sleep for a short time if you're not emitting anything...
        try {
            Thread.sleep(1);
        } catch (InterruptedException e) {
            log.error("Error: ", e);
        }
    }
```

This method above emits the tuples. The Storm framework calls this method. This function only emits at most the given maximum tuples per period.

!!! note "Why a DUMMY_ID?"

    When the spout emits the randomly generated tuple, it attaches a ```DUMMY_ID``` to it. In Storm terms, this is a message ID. By adding a message ID, this tuple can be made to flow reliably. The Bullet component that receives this tuple (Filter bolt) acknowledges or "acks" this tuple. If the tuple did not make it to Filter bolt within a configured timeout window, Storm will call a ```fail(Object messageId)``` method on the spout. This particular spout does not define one and hence the usage of a ```DUMMY_ID```. If your source of data can identify records uniquely and you can re-emit them on a fail, you should attach that actual ID in place of the ```DUMMY_ID```.

```java
    private BulletRecord generateRecord() {
        BulletRecord record = new BulletRecord();
        String uuid = UUID.randomUUID().toString();

        record.setString(STRING, uuid);
        record.setLong(LONG, (long) generatedThisPeriod);
        record.setDouble(DOUBLE, random.nextDouble());
        record.setString(TYPE, STRING_POOL[random.nextInt(STRING_POOL.length)]);
        record.setLong(DURATION, System.currentTimeMillis() % INTEGER_POOL[random.nextInt(INTEGER_POOL.length)]);

        Map<String, Boolean> booleanMap = new HashMap<>(4);
        booleanMap.put(uuid.substring(0, 8), random.nextBoolean());
        booleanMap.put(uuid.substring(9, 13), random.nextBoolean());
        booleanMap.put(uuid.substring(14, 18), random.nextBoolean());
        booleanMap.put(uuid.substring(19, 23), random.nextBoolean());
        record.setBooleanMap(BOOLEAN_MAP, booleanMap);

        Map<String, Long> statsMap = new HashMap<>(4);
        statsMap.put(PERIOD_COUNT, periodCount);
        statsMap.put(RECORD_NUMBER, periodCount * maxPerPeriod + generatedThisPeriod);
        statsMap.put(NANO_TIME, System.nanoTime());
        statsMap.put(TIMESTAMP, System.currentTimeMillis());
        record.setLongMap(STATS_MAP, statsMap);

        Map<String, String> randomMapA = new HashMap<>(2);
        Map<String, String> randomMapB = new HashMap<>(2);
        randomMapA.put(RANDOM_MAP_KEY_A, STRING_POOL[random.nextInt(STRING_POOL.length)]);
        randomMapA.put(RANDOM_MAP_KEY_B, STRING_POOL[random.nextInt(STRING_POOL.length)]);
        randomMapB.put(RANDOM_MAP_KEY_A, STRING_POOL[random.nextInt(STRING_POOL.length)]);
        randomMapB.put(RANDOM_MAP_KEY_B, STRING_POOL[random.nextInt(STRING_POOL.length)]);
        record.setListOfStringMap(LIST, asList(randomMapA, randomMapB));

        return record;
    }
```

This method generates some fields randomly and inserts them into a BulletRecord. Note that the BulletRecord is typed and all data must be inserted with the proper types.

If you put Bullet on your data, you will need to write a Spout (or a topology if your reading is complex), that reads from your data source and emits BulletRecords with the fields you wish to be query-able placed into a BulletRecord similar to this example.

### PubSub

We used the [DRPC PubSub](pubsub/storm-drpc.md) since we were using the Storm Backend. This code was included in the Bullet Storm artifact that we downloaded (the JAR with dependencies). We configured the Backend to use this PubSub by adding these settings to the YAML file that we passed to our Storm topology. Notice that we set the context to ```QUERY_PROCESSING``` since this is the Backend.

```yaml
bullet.pubsub.context.name: "QUERY_PROCESSING"
bullet.pubsub.class.name: "com.yahoo.bullet.storm.drpc.DRPCPubSub"
bullet.pubsub.storm.drpc.function: "bullet-query"
```

For the Web Service, we passed in a YAML file that pointed to our DRPC server that was part of the Storm cluster we launched. Notice that we set the context to ```QUERY_SUBMISSION``` since this is the Web Service.

```yaml
bullet.pubsub.context.name: "QUERY_SUBMISSION"
bullet.pubsub.class.name: "com.yahoo.bullet.storm.drpc.DRPCPubSub"
bullet.pubsub.storm.drpc.servers:
  - 127.0.0.1
bullet.pubsub.storm.drpc.function: "bullet-query"
bullet.pubsub.storm.drpc.http.protocol: "http"
bullet.pubsub.storm.drpc.http.port: "3774"
bullet.pubsub.storm.drpc.http.path: "drpc"
bullet.pubsub.storm.drpc.http.connect.retry.limit: 3
bullet.pubsub.storm.drpc.http.connect.timeout.ms: 1000
```

### Web Service

We launched the Web Service using two custom files - a PubSub configuration YAML file and JSON schema file.

The JSON columns file contains the schema for our data specified in JSON. Since our schema is not going to change, we use the Web Service to serve it from a file. If your schema changes dynamically, you will need to provide your own endpoint to the UI.

The following is a snippet from the [JSON file](https://github.com/yahoo/bullet-docs/blob/master/examples/web-service/example_columns.json). Notice how the types of the fields are specified. Also, if you have generated BulletRecord with Map fields whose keys are known, you can specify them here using ```enumerations```.

```javascript
[
    {
        "name": "probability",
        "type": "DOUBLE",
        "description": "Generated from Random#nextDouble"
    },
    ...
    {
        "name": "stats_map",
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
The contents of the [PubSub configuration file](https://github.com/yahoo/bullet-docs/blob/master/examples/web-service/example_drpc_pubsub_config.yaml) was discussed in the [PubSub section above](#pubsub).

### UI

Finally, we configured the UI with the custom environment specific settings file. We did not add any environments since we only had the one.

```javascript
{
  "default": {
    "queryHost": "http://localhost:9999",
    "queryNamespace": "api/bullet",
    "queryPath": "query",
    "schemaHost": "http://localhost:9999",
    "schemaNamespace": "api/bullet",
    "helpLinks": [
      {
        "name": "Examples",
        "link": "https://yahoo.github.io/bullet-docs/ui/usage"
      }
    ],
    "bugLink": "https://github.com/yahoo/bullet-ui/issues",
    "modelVersion": 2,
    "migrations": {
      "deletions": "result"
    },
    "defaultValues": {
    "defaultValues": {
      "aggregationMaxSize": 1024,
      "rawMaxSize": 500,
      "durationMaxSecs": 540,
      "distributionNumberOfPoints": 11,
      "distributionQuantilePoints": "0, 0.25, 0.5, 0.75, 0.9, 1",
      "distributionQuantileStart": 0,
      "distributionQuantileEnd": 1,
      "distributionQuantileIncrement": 0.1,
      "queryTimeoutSecs": 3,
      "sketches": {
        "countDistinctMaxEntries": 16384,
        "groupByMaxEntries": 512,
        "distributionMaxEntries": 1024,
        "distributionMaxNumberOfPoints": 200,
        "topKMaxEntries": 1024,
        "topKErrorType": "No False Negatives"
      },
      "metadataKeyMapping": {
        "theta": "theta",
        "uniquesEstimate": "uniques_estimate",
        "queryCreationTime": "query_receive_time",
        "queryTerminationTime": "query_finish_time",
        "estimatedResult": "was_estimated",
        "standardDeviations": "standard_deviations",
        "normalizedRankError": "normalized_rank_error",
        "maximumCountError": "maximum_count_error",
        "itemsSeen": "items_seen",
        "minimumValue": "minimum_value",
        "maximumValue": "maximum_value"
      }
    }
  }
}
```

Since we served our schema through the same Web Service as our queries, both these point to our Web Service. Note that there is no ```schemaPath``` because it must be the constant string ```columns```. If you define a custom endpoint for your schema, you must ensure that it can be obtained by making a GET request to ```schemaHost/schemaNamespace/columns```.
