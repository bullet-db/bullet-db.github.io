# Quick Start on Storm

This section gets you running a mock instance of Bullet to play around with. The instance will run using [Bullet on Storm](../backend/storm-setup.md) and use the [REST Pubsub](../pubsub/rest.md). Since we do not have an actual data source, we will produce some fake data and convert it into [Bullet Records](../backend/ingestion.md) in a [custom Storm spout](https://github.com/bullet-db/bullet-db.github.io/blob/master/examples/storm/src/main/java/com/yahoo/bullet/storm/examples/RandomSpout.java). If you want to use Bullet for your data, you will need to do read and convert your data to Bullet Records in a similar manner.

At the end of this section, you will have:

  * Setup the Bullet topology using a custom spout on [bullet-storm-1.3.0](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-1.3.0)
  * Setup the [Web Service](../ws/setup.md) talking to the topology and serving a schema for your UI using [bullet-service-1.4.1](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-1.4.1)
  * Setup the [REST PubSub](../pubsub/rest.md) talking to the topology and Web Service using [bullet-core-1.5.0](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-1.5.0).
  * Setup the [UI](../ui/setup.md) talking to the Web Service using [bullet-ui-1.1.0](https://github.com/bullet-db/bullet-ui/releases/tag/v1.1.0)

**Prerequisites**

  * You will need to be on an Unix-based system (Mac OS X, Ubuntu ...) with ```curl``` installed
  * You will need [JDK 8](https://jdk.java.net/java-se-ri/8-MR3) installed
  * You will need enough CPU and RAM on your machine to run about 8-10 JVMs in ```server``` mode. You should have at least 2 GB free space on your disk. We will be setting up a Storm cluster with multiple components, an embedded Tomcat server and a Node server.

## Install Script

Simply run:

```bash
curl -sLo- https://raw.githubusercontent.com/bullet-db/bullet-db.github.io/src/examples/install-all-storm.sh | bash
```

This will setup a local Storm cluster, a Bullet running on it, the Bullet Web Service and a Bullet UI for you. Once everything has launched, you should be able to go to the Bullet UI running locally at [http://localhost:8800](http://localhost:8800). You can then [**continue this guide from here**](#playing-around-with-the-instance).

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
curl -LO https://github.com/bullet-db/bullet-db.github.io/releases/download/v1.1.0/examples_artifacts.tar.gz
tar -xzf examples_artifacts.tar.gz
export BULLET_EXAMPLES=$BULLET_HOME/bullet-examples
```

#### Step 2: Install Storm 2.2

```bash
cd $BULLET_HOME/backend
curl -LO https://downloads.apache.org/storm/apache-storm-2.2.0/apache-storm-2.2.0.zip
unzip apache-storm-2.2.0.zip
export PATH=$(pwd)/apache-storm-2.2.0/bin/:$PATH
```
#### Step 3: Launch Storm components

Launch each of the following components, in order and wait for the commands to go through. You may have to do these one at a time. You will see a JVM being launched for each one and connection messages as the components communicate through Zookeeper.

```bash
storm dev-zookeeper &
storm nimbus &
storm ui &
storm logviewer &
storm supervisor &
```

It may take 30-60 seconds for all the components to launch.

Once everything is up without errors, visit [http://localhost:8080](http://localhost:8080) and see if the Storm UI loads.

!!! note "Local mode cleanup"

    If you notice any problems while setting up storm or while relaunching a topology, it may be because some state is corrupted. When running Storm in this fashion, states and serializations are stored in ```storm-local``` and ```/tmp/```. You may want to ```rm -rf storm-local/* /tmp/dev-storm-zookeeper``` to clean up this state before relaunching Storm components. See the [tear down section](#teardown) on how to kill any running instances.

### Setting up the example Bullet topology

Now that Storm is up and running, we can put Bullet on it. We will use an example spout that runs on Bullet 1.2.0 on our Storm cluster. The source is available [here](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/storm). This was part of the artifact that you installed in Step 1.

#### Step 4: Setup the Storm example

```bash
cp $BULLET_EXAMPLES/backend/storm/* $BULLET_HOME/backend/storm
```

!!! note "Settings"

    Take a look at bullet_settings.yaml for the settings that are being overridden for this example. You can add or change settings as you like by referring to [core Bullet settings in bullet_defaults.yaml](https://github.com/bullet-db/bullet-core/blob/master/src/main/resources/bullet_defaults.yaml) and [Storm settings in bullet_storm_defaults.yaml](https://github.com/bullet-db/bullet-storm/blob/master/src/main/resources/bullet_storm_defaults.yaml). In particular, we have [customized these settings](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/storm/src/main/resources/bullet_settings.yaml) that affect the Bullet queries you can run:

    ```bullet.query.aggregation.raw.max.size: 500``` The max ```RAW``` records you can fetch is 500.

    ```bullet.query.aggregation.count.distinct.sketch.entries: 16384``` We can count 16384 unique values exactly. Approximates after.

    ```bullet.query.aggregation.group.sketch.entries: 1024``` The max unique groups can be 1024. Uniform sample after.

    ```bullet.query.aggregation.distribution.sketch.entries: 1024``` Determines the normalized rank error for distributions.

    ```bullet.query.aggregation.top.k.sketch.entries: 1024``` 0.75 times this number is the number of unique items for which counts can be done exactly. Approximates after.

    ```bullet.query.aggregation.distribution.max.points: 200``` The maximum number of points you can generate, use or provide for a Distribution aggregation.

!!! note "Want to tweak the example topology code?"

    You will need to clone the [examples repository](https://github.com/bullet-db/bullet-db.github.io/tree/src/examples/storm) and customize it. To build the examples, you'll need to install [Maven 3](https://maven.apache.org/install.html).

    ```cd $BULLET_HOME && git clone git@github.com:bullet-db/bullet-db.github.io.git```

    ```cd bullet-db.github.io/examples/storm && mvn package```

    You will find the ```bullet-storm-example-1.0-SNAPSHOT-jar-with-dependencies.jar``` in ```$BULLET_HOME/bullet-db.github.io/examples/storm/target/```

    You can also make the ```examples_artifacts.tar.gz``` file with all the settings that is placed in ```$BULLET_EXAMPLES``` by just running ```make``` in the ```bullet-db.github.io/examples/``` folder.

#### Step 5: Launch the topology

```bash
cd $BULLET_HOME/backend/storm && ./launch.sh
```
Visit the UI and see if the topology is up. You should see the ```DataSource``` spout begin emitting records.

!!! note "Where is this data coming from?"

    This data is randomly generated by the [custom Storm spout](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/storm/src/main/java/com/yahoo/bullet/storm/examples/RandomSpout.java) that is in the example topology you just launched. In practice, your spout would read from an actual data source such as Kafka etc. See [below](#storm-topology) for more details about this random data spout.

### Setting up the Bullet Web Service

#### Step 6: Install the Bullet Web Service

```bash
cd $BULLET_HOME/service
curl -Lo bullet-service.jar https://repo1.maven.org/maven2/com/yahoo/bullet/bullet-service/1.4.1/bullet-service-1.4.1-embedded.jar
cp $BULLET_EXAMPLES/web-service/example* $BULLET_HOME/service/
```

#### Step 7: Launch the Web Service

```bash
cd $BULLET_HOME/service
java -jar bullet-service.jar --bullet.pubsub.config=example_rest_pubsub_config.yaml --bullet.schema.file=example_columns.json --bullet.pubsub.builtin.rest.enabled=true --server.port=9999  --logging.path=. --logging.file=log.txt &> log.txt &
```

Note that we turned on the built-in REST pubsub in the Web Service when launching it. The REST PubSub is bundled into the Bullet API by default, so no additional jars are needed.

You can verify that it is up by running a Bullet query or getting the example columns through the API:

```bash
curl -s -H 'Content-Type: text/plain' -X POST -d 'SELECT * FROM STREAM(10000, TIME) LIMIT 1' http://localhost:9999/api/bullet/queries/sse-query
curl -s http://localhost:9999/api/bullet/columns
```

!!! note "Settings"

    Take a look at example_query_settings.yaml for the settings that are being overridden for this example. You can add or change the query settings (used by BQL when creating the query) by referring to [core Bullet settings in bullet_defaults.yaml](https://github.com/bullet-db/bullet-core/blob/master/src/main/resources/bullet_defaults.yaml). We have [customized these settings](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/web-service/example_query_settings.yaml):

    ```bullet.query.aggregation.max.size: 1024``` The max records you can fetch for any query is 1024.


### Setting up the Bullet UI

#### Step 8: Install Node

```bash
curl -s https://raw.githubusercontent.com/creationix/nvm/v0.38.0/install.sh | bash
source ~/.bashrc
nvm install v16.9.0
nvm use v16.9.0
```

#### Step 9: Install the Bullet UI

```bash
cd $BULLET_HOME/ui
curl -LO https://github.com/bullet-db/bullet-ui/releases/download/v1.1.0/bullet-ui-v1.1.0.tar.gz
tar -xzf bullet-ui-v1.1.0.tar.gz
cp $BULLET_EXAMPLES/ui/env-settings.json config/
```

#### Step 10: Launch the UI

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
curl -sLo- https://raw.githubusercontent.com/bullet-db/bullet-db.github.io/src/examples/install-all-storm.sh | bash -s cleanup
```

If you were performing the steps yourself, you can also manually cleanup **all the components and all the downloads** using:

|                |                                                                  |
| -------------- | ---------------------------------------------------------------- |
| UI             | ```pkill -f [e]xpress-server.js```                               |
| Web Service    | ```pkill -f [e]xample_rest_pubsub_config.yaml```                      |
| Storm          | ```pkill -f [a]pache-storm-2.2.0```                              |
| File System    | ```rm -rf $BULLET_HOME /tmp/dev-storm-zookeeper```  |

This does *not* delete ```$HOME/.nvm``` and some extra lines nvm may have added to your ```$HOME/{.profile, .bash_profile, .zshrc, .bashrc}```.

## What did we do?

This section will go over the various custom pieces this example plugged into Bullet, so you can better understand what we did.

### Storm topology

The topology was the Bullet topology plugged in with a custom spout. This spout is implemented in this [example project](https://github.com/bullet-db/bullet-db.github.io/blob/src/examples/storm/) and was already built for you when you [downloaded the examples](#step-1-setup-directories-and-examples). It does not read from any data source and just produces random, structured data. It also produces only up to a maximum number of records in a given period. Both this maximum and the length of a period are configurable. If you examine $BULLET_HOME/backend/storm/launch.sh, you'll see the following:

```bash
storm jar bullet-storm-example-1.0-SNAPSHOT-jar-with-dependencies.jar \
          com.yahoo.bullet.Topology \
          --bullet-conf ./bullet_settings.yaml \
          --bullet-spout com.yahoo.bullet.storm.examples.RandomSpout \
          --bullet-spout-parallelism 1 \
          ...
          --bullet-spout-arg 20 \
          --bullet-spout-arg 101 \
          ...
```

This command launches the jar (an uber or "fat" jar) containing the custom spout code and all dependencies you copied in Step 5. We pass the name of your spout class with ```--bullet-spout com.yahoo.bullet.storm.examples.RandomSpout``` to the Bullet main class ```com.yahoo.bullet.Topology``` with two arguments ```--bullet-spout-arg 20``` and ```--bullet-spout-arg 101```. The first argument tells the spout to generate at most 20 tuples (records) in a period and the second argument says a period is 101 ms long.

The settings defined by ```--bullet-conf ./bullet_settings.yaml``` and the arguments here run all components in the topology with a parallelism of 1. So there will be one spout that is producing ~200 rps.

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
            return;
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
private Map<String, String> makeRandomMap() {
    Map<String, String> randomMap = new HashMap<>(2);
    randomMap.put(RANDOM_MAP_KEY_A, STRING_POOL[random.nextInt(STRING_POOL.length)]);
    randomMap.put(RANDOM_MAP_KEY_B, STRING_POOL[random.nextInt(STRING_POOL.length)]);
    return randomMap;
}

private BulletRecord generateRecord() {
    BulletRecord record = new AvroBulletRecord();
    String uuid = UUID.randomUUID().toString();

    record.setString(STRING, uuid);
    record.setLong(LONG, (long) generatedThisPeriod);
    record.setDouble(DOUBLE, random.nextDouble());
    record.setDouble(GAUSSIAN, random.nextGaussian());
    record.setString(TYPE, STRING_POOL[random.nextInt(STRING_POOL.length)]);
    record.setLong(DURATION, System.currentTimeMillis() % INTEGER_POOL[random.nextInt(INTEGER_POOL.length)]);

    record.setStringMap(SUBTYPES_MAP, makeRandomMap());

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

    record.setListOfStringMap(LIST, asList(makeRandomMap(), makeRandomMap()));

    return record;
}
```

This ```generateRecord``` method generates some fields randomly and inserts them into a BulletRecord. Note that the BulletRecord is typed and all data must be inserted with the proper types.

If you put Bullet on your data, you will need to write a spout (or a topology if your reading is complex), that reads from your data source and emits BulletRecords with the fields you wish to be query-able placed into a BulletRecord similar to this example.

### PubSub

We used the [REST PubSub](../pubsub/rest.md). Note that even though we support a DRPC PubSub, it doesn't actually support windowing so we have not used it for this example. We configured the Backend to use this PubSub by adding these settings to the YAML file that we passed to our Storm topology. Notice that we set the context to ```QUERY_PROCESSING``` since this is the Backend. We do not set ```bullet.pubsub.rest.result.url``` because each query sent to the topology has this information so that the results could be returned back to it.


```yaml
bullet.pubsub.context.name: "QUERY_PROCESSING"
bullet.pubsub.class.name: "com.yahoo.bullet.pubsub.rest.RESTPubSub"
bullet.pubsub.message.serde.class.name: "com.yahoo.bullet.pubsub.IdentityPubSubMessageSerDe"
bullet.pubsub.rest.query.urls:
    - "http://localhost:9999/api/bullet/pubsub/query"
```

For the Web Service, we passed in a YAML file that pointed to itself for the REST endpoints that serve as the PubSub interface. Notice that we set the context to ```QUERY_SUBMISSION``` since this is the Web Service.

```yaml
bullet.pubsub.context.name: "QUERY_SUBMISSION"
bullet.pubsub.class.name: "com.yahoo.bullet.pubsub.rest.RESTPubSub"
bullet.pubsub.message.serde.class.name: "com.yahoo.bullet.pubsub.IdentityPubSubMessageSerDe"
bullet.pubsub.rest.query.urls:
    - "http://localhost:9999/api/bullet/pubsub/query"
bullet.pubsub.rest.result.url: "http://localhost:9999/api/bullet/pubsub/result"
bullet.pubsub.rest.subscriber.connect.timeout.ms: 5000
bullet.pubsub.rest.publisher.connect.timeout.ms: 5000
bullet.pubsub.rest.subscriber.max.uncommitted.messages: 100
bullet.pubsub.rest.result.subscriber.min.wait.ms: 10
bullet.pubsub.rest.query.subscriber.min.wait.ms: 10
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
    "queryNamespace": "api/bullet/queries",
    "queryPath": "ws-query",
    "validationPath": "validate-query",
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
    "modelVersion": 4,
    "migrations": {
      "deletions": "query"
    },
    "defaultValues": {
      "aggregationMaxSize": 1024,
      "rawMaxSize": 500,
      "durationMaxSecs": 9007199254740,
      "distributionNumberOfPoints": 11,
      "distributionQuantilePoints": "0, 0.25, 0.5, 0.75, 0.9, 1",
      "distributionQuantileStart": 0,
      "distributionQuantileEnd": 1,
      "distributionQuantileIncrement": 0.1,
      "windowEmitFrequencyMinSecs": 1,
      "everyForRecordBasedWindow": 1,
      "everyForTimeBasedWindow": 2000,
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
