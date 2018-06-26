# Quick Start on Storm

!!! note "NOTE: This is an old version of Bullet"
    The version of Bullet this QuickStart uses does not support the newest functionality such as Windowing. We are working hard to get new documentation up as soon as possible. Use [the Spark QuickStart](spark.md) to see all the latest features. An updated quickstart for Storm is coming soon.

This section gets you running a mock instance of Bullet to play around with. The instance will run using [Bullet on Storm](../backend/storm-setup.md) and use the [DRPC Pubsub](../pubsub/storm-drpc.md). Since we do not have an actual data source, we will produce some fake data and convert it into [Bullet Records](../backend/ingestion.md) in a [custom Storm spout](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/storm/src/main/java/com/yahoo/bullet/storm/examples/RandomSpout.java). If you want to use Bullet for your data, you will need to do read and convert your data to Bullet Records in a similar manner.

At the end of this section, you will have:

  * Setup the Bullet topology using a custom spout on [bullet-storm-0.6.2](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.6.2)
  * Setup the [Web Service](../ws/setup.md) talking to the topology and serving a schema for your UI using [bullet-service-0.1.1](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.1.1)
  * Setup the [DRPC PubSub](../pubsub/storm-drpc.md) talking to the topology and Web Service.
  * Setup the [UI](../ui/setup.md) talking to the Web Service using [bullet-ui-0.4.0](https://github.com/bullet-db/bullet-ui/releases/tag/v0.4.0)

**Prerequisites**

  * You will need to be on an Unix-based system (Mac OS X, Ubuntu ...) with ```curl``` installed
  * You will need [JDK 8](http://www.oracle.com/technetwork/java/javase/downloads/index.html) installed
  * You will need enough CPU and RAM on your machine to run about 8-10 JVMs in ```server``` mode. You should have at least 2 GB free space on your disk. We will be setting up a Storm cluster with multiple components, a couple of Jetty instances and a Node server.

## Install Script

Simply run:

```bash
curl -sLo- https://raw.githubusercontent.com/bullet-db/bullet-db.github.io/v0.4.0/examples/install-all.sh | bash
```

This will setup a local Storm cluster, a Bullet running on it, the Bullet Web Service and a Bullet UI for you. Once everything has launched, you should be able to go to the Bullet UI running locally at [http://localhost:8800](http://localhost:8800). You can then [**continue this guide from here**](#what-did-we-do).

!!! note "Want to DIY?"
    If you want to manually run all the commands or if the script died while doing something above (might want to perform the [teardown](#teardown) first), you can continue below.


## Manual Installation

### Setting up Storm

To set up a clean working environment, let's start with creating some directories.

#### Step 1: Setup directories and examples

```bash
export BULLET_HOME=$(pwd)/bullet-quickstart
mkdir -p $BULLET_HOME/backend/storm
mkdir -p $BULLET_HOME/service
mkdir -p $BULLET_HOME/ui
cd $BULLET_HOME
curl -LO https://github.com/bullet-db/bullet-db.github.io/releases/download/v0.4.0/examples_artifacts.tar.gz
tar -xzf examples_artifacts.tar.gz
export BULLET_EXAMPLES=$BULLET_HOME/bullet-examples
```

#### Step 2: Install Storm 1.1

```bash
cd $BULLET_HOME/backend
curl -O http://apache.org/dist/storm/apache-storm-1.1.2/apache-storm-1.1.2.zip
unzip apache-storm-1.1.2.zip
export PATH=$(pwd)/apache-storm-1.1.2/bin/:$PATH
```
Add a DRPC server setting to the Storm config:

```bash
echo 'drpc.servers: ["127.0.0.1"]' >> apache-storm-1.1.2/conf/storm.yaml
```

#### Step 3: Launch Storm components

Launch each of the following components, in order and wait for the commands to go through. You may have to do these one at a time. You will see a JVM being launched for each one and connection messages as the components communicate through Zookeeper.

```bash
storm dev-zookeeper &
storm nimbus &
storm drpc &
storm ui &
storm logviewer &
storm supervisor &
```

It may take 30-60 seconds for all the components to launch.

Once everything is up without errors, visit [http://localhost:8080](http://localhost:8080) and see if the Storm UI loads.

#### Step 4: Test Storm (Optional)

Before Bullet, test to see if Storm and DRPC are up and running by launching a example topology that comes with your Storm installation:

```bash
storm jar apache-storm-1.1.2/examples/storm-starter/storm-starter-topologies-1.1.2.jar org.apache.storm.starter.BasicDRPCTopology topology
```

Visit your UI with a browser and see if a topology with name "topology" is running. If everything is good, you should be able to ping DRPC with:

```bash
curl localhost:3774/drpc/exclamation/foo
```

and get back a ```foo!```. Any string you pass as part of the URL is returned to you with a "!" at the end.

Kill this topology after with:

```bash
storm kill topology
```

!!! note "Local mode cleanup"

    If you notice any problems while setting up storm or while relaunching a topology, it may be because some state is corrupted. When running Storm in this fashion, states and serializations are stored in ```storm-local``` and ```/tmp/```. You may want to ```rm -rf storm-local/* /tmp/dev-storm-zookeeper``` to clean up this state before relaunching Storm components. See the [tear down section](#teardown) on how to kill any running instances.

### Setting up the example Bullet topology

Now that Storm is up and running, we can put Bullet on it. We will use an example Spout that runs on Bullet 0.4.3 on our Storm cluster. The source is available [here](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/storm). This was part of the artifact that you installed in Step 1.

#### Step 5: Setup the Storm example

```bash
cp $BULLET_EXAMPLES/storm/* $BULLET_HOME/backend/storm
```

!!! note "Settings"

    Take a look at bullet_settings.yaml for the settings that are being overridden for this example. You can add or change settings as you like by referring to [core Bullet settings in bullet_defaults.yaml](https://github.com/bullet-db/bullet-core/blob/master/src/main/resources/bullet_defaults.yaml) and [Storm settings in bullet_storm_defaults.yaml](https://github.com/bullet-db/bullet-storm/blob/master/src/main/resources/bullet_storm_defaults.yaml). In particular, we have [customized these settings](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/storm/src/main/resources/bullet_settings.yaml) that affect the Bullet queries you can run:

    ```bullet.query.max.duration: 570000``` Longest query time can be 570s. The Storm cluster default DRPC timeout is 600s.

    ```bullet.query.aggregation.raw.max.size: 500``` The max ```RAW``` records you can fetch is 500.

    ```bullet.query.aggregation.max.size: 1024``` The max records you can fetch for any query is 1024.

    ```bullet.query.aggregation.count.distinct.sketch.entries: 16384``` We can count 16384 unique values exactly. Approximates after.

    ```bullet.query.aggregation.group.sketch.entries: 1024``` The max unique groups can be 1024. Uniform sample after.

    ```bullet.query.aggregation.distribution.sketch.entries: 1024``` Determines the normalized rank error for distributions.

    ```bullet.query.aggregation.top.k.sketch.entries: 1024``` 0.75 times this number is the number of unique items for which counts can be done exactly. Approximates after.

    ```bullet.query.aggregation.distribution.max.points: 200``` The maximum number of points you can generate, use or provide for a Distribution aggregation.

!!! note "Want to tweak the example topology code?"

    You will need to clone the [examples repository](https://github.com/bullet-db/bullet-db.github.io/tree/master/examples/storm) and customize it. To build the examples, you'll need to install [Maven 3](https://maven.apache.org/install.html).

    ```cd $BULLET_HOME && git clone git@github.com:yahoo/bullet-docs.git```

    ```cd bullet-docs/examples/storm && mvn package```

    You will find the ```bullet-storm-example-1.0-SNAPSHOT-jar-with-dependencies.jar``` in ```$BULLET_HOME/bullet-docs/examples/storm/target/```

    You can also make the ```examples_artifacts.tar.gz``` file with all the settings that is placed in ```$BULLET_EXAMPLES``` by just running ```make``` in the ```bullet-docs/examples/``` folder.

#### Step 6: Launch the topology

```bash
cd $BULLET_HOME/backend/storm && ./launch.sh
```
Visit the UI and see if the topology is up. You should see the ```DataSource``` spout begin emitting records.

Test the Bullet topology by:

```bash
curl -s -X POST -d '{"id":"", "content":"{}"}' http://localhost:3774/drpc/bullet-query
```

You should get a random record (serialized as a String inside a JSON message sent back through the PubSub) from Bullet.

!!! note "What is this data?"

    This data is randomly generated by the [custom Storm spout](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/storm/src/main/java/com/yahoo/bullet/storm/examples/RandomSpout.java) that is in the example topology you just launched. In practice, your spout would read from an actual data source such as Kafka instead. See [below](#storm-topology) for more details about this random data spout.

### Setting up the Bullet Web Service

#### Step 7: Install the Bullet Web Service

```bash
cd $BULLET_HOME/service
curl -Lo bullet-service.jar http://jcenter.bintray.com/com/yahoo/bullet/bullet-service/0.1.1/bullet-service-0.1.1-embedded.jar
cp $BULLET_EXAMPLES/web-service/example* $BULLET_HOME/service/
cp $BULLET_EXAMPLES/storm/*jar-with-dependencies.jar $BULLET_HOME/service/bullet-storm-jar-with-dependencies.jar
```

#### Step 8: Launch the Web Service

```bash
cd $BULLET_HOME/service
java -Dloader.path=bullet-storm-jar-with-dependencies.jar -jar bullet-service.jar --bullet.pubsub.config=example_drpc_pubsub_config.yaml --bullet.schema.file=example_columns.json --server.port=9999  --logging.path=. --logging.file=log.txt &> log.txt &
```
You can verify that it is up by running a Bullet query or getting the example columns through the API:

```bash
curl -s -H 'Content-Type: text/plain' -X POST -d '{}' http://localhost:9999/api/bullet/query
curl -s http://localhost:9999/api/bullet/columns
```

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
curl -LO https://github.com/bullet-db/bullet-ui/releases/download/v0.4.0/bullet-ui-v0.4.0.tar.gz
tar -xzf bullet-ui-v0.4.0.tar.gz
cp $BULLET_EXAMPLES/ui/env-settings.json config/
```

#### Step 11: Launch the UI

```bash
PORT=8800 node express-server.js &
```

Visit [http://localhost:8800](http://localhost:8800) to query your topology with the UI. See [UI usage](../ui/usage.md) for some example queries and interactions using this UI. You see what the Schema means by visiting the Schema section.

!!! note "Running it remotely?"

    If you access the UI from another machine than where your UI is actually running, you will need to edit ```config/env-settings.json```. Since the UI is a client-side app, the machine that your browser is running on will fetch the UI and attempt to use these settings to talk to the Web Service. Since they point to localhost by default, your browser will attempt to connect there and fail. An easy fix is to change ```localhost``` in your env-settings.json to point to the host name where you will hosting the UI. This will be the same as the UI host you use in the browser. You can also do a local port forward on the machine accessing the UI by running: ```ssh -N -L 8800:localhost:8800 -L 9999:localhost:9999 hostname-of-the-quickstart-components 2>&1```

##  Playing around with the instance

Check out and follow along with the [UI Usage](../ui/usage.md) page as it shows you some queries you can run using this UI.

## Teardown

If you were using the [Install Script](#install-script) or if you don't want to manually bring down everything, you can run:

```bash
curl -sLo- https://raw.githubusercontent.com/bullet-db/bullet-db.github.io/v0.4.0/examples/install-all.sh | bash -s cleanup
```

If you were performing the steps yourself, you can also manually cleanup **all the components and all the downloads** using:

|                |                                                                  |
| -------------- | ---------------------------------------------------------------- |
| UI             | ```pkill -f [e]xpress-server.js```                               |
| Web Service    | ```pkill -f [e]xample_drpc_pubsub_config.yaml```                      |
| Storm          | ```pkill -f [a]pache-storm-1.1.2```                              |
| File System    | ```rm -rf $BULLET_HOME /tmp/dev-storm-zookeeper /tmp/jetty-*```  |

This does *not* delete ```$HOME/.nvm``` and some extra lines nvm may have added to your ```$HOME/{.profile, .bash_profile, .zshrc, .bashrc}```.

## What did we do?

This section will go over the various custom pieces this example plugged into Bullet, so you can better understand what we did.

### Storm topology

The topology was the Bullet topology plugged in with a custom spout. This spout is implemented in this [example project](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/storm/) and was already built for you when you [downloaded the examples](#step-1-setup-directories-and-examples). It does not read from any data source and just produces random, structured data. It also produces only up to a maximum number of records in a given period. Both this maximum and the length of a period are configurable. If you examine $BULLET_HOME/backend/storm/launch.sh, you'll see the following:

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


Let's look at the [custom spout code](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/storm/src/main/java/com/yahoo/bullet/storm/examples/RandomSpout.java) that generates the data.

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

We used the [DRPC PubSub](../pubsub/storm-drpc.md) since we were using the Storm Backend. This code was included in the Bullet Storm artifact that we downloaded (the JAR with dependencies). We configured the Backend to use this PubSub by adding these settings to the YAML file that we passed to our Storm topology. Notice that we set the context to ```QUERY_PROCESSING``` since this is the Backend.

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
The contents of the [PubSub configuration file](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/web-service/example_drpc_pubsub_config.yaml) was discussed in the [PubSub section above](#pubsub).

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
    "bugLink": "https://github.com/bullet-db/bullet-ui/issues",
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
