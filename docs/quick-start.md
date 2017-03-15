# Quick Start

This section gets you running a mock instance of Bullet to play around with. The instance will run using [Bullet on Storm](backend/setup-storm.md). Since we do not have an actual data source, we will produce some fake data and convert it into [Bullet Records](backend/ingestion.md) in a [custom Storm spout](https://github.com/yahoo/bullet-docs/blob/master/examples/storm/src/main/java/com/yahoo/bullet/storm/examples/RandomSpout.java). If you want to use Bullet for your data, you will need to do read and convert your data to Bullet Records in a similar manner.

By the following the steps in this section, you will:

  * Setup the Bullet topology using a custom spout on [bullet-storm-0.3.1](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.3.1)
  * Setup the [Web Service](ws/setup.md) talking to the topology and serving a schema for your UI using [bullet-service-0.0.1](https://github.com/yahoo/bullet-service/releases/tag/bullet-service-0.0.1)
  * Setup the [UI](ui/setup.md) talking to the Web Service using [bullet-ui-0.1.0](https://github.com/yahoo/bullet-ui/releases/tag/v0.1.0)

**Prerequisites**

  * You will need to be on an Unix-based system (Mac OS X, Ubuntu ...)
  * You will need [JDK 8](http://www.oracle.com/technetwork/java/javase/downloads/index.html) installed.
  * You will need enough CPU and RAM on your machine to run about 8-10 JVMs. You will be setting up a Storm cluster with multiple components, a couple of Jetty instances and a Node server

## Quicker Start

Don't want to follow all these Steps? Make sure you have your prerequisites installed and you can just run:

```bash
export BULLET_HOME=$(pwd)/bullet-quickstart
curl -sLo- https://raw.githubusercontent.com/yahoo/bullet-docs/v0.1.2/examples/install-all.sh | bash
```

This will run all the Steps for you. Once everything has launched, you should be able to go to the Bullet UI running locally at [http://localhost:8800](http://localhost:8800). You can then continue this guide from [here](#what-did-we-do).

If you want to manually run all the commands  or if something failed above (might want to perform the [teardown](#teardown) first), you can continue below.

---

## Setting up Storm


To set up a clean working environment, let's start with creating some directories.

#### Step 1: Setup directories and examples

```bash
export BULLET_HOME=$(pwd)/bullet-quickstart
mkdir -p $BULLET_HOME/backend/storm
mkdir -p $BULLET_HOME/service
mkdir -p $BULLET_HOME/ui
cd $BULLET_HOME
curl -LO https://github.com/yahoo/bullet-docs/releases/download/v0.1.2/examples_artifacts.tar.gz
tar -xzf examples_artifacts.tar.gz
export BULLET_EXAMPLES=$BULLET_HOME/bullet-examples
```

#### Step 2: Install Storm 1.0

```bash
cd $BULLET_HOME/backend
curl -O http://apache.org/dist/storm/apache-storm-1.0.3/apache-storm-1.0.3.zip
unzip apache-storm-1.0.3.zip
export PATH=$(pwd)/apache-storm-1.0.3/bin/:$PATH
```
Add a DRPC server setting to the Storm config:

```bash
echo 'drpc.servers: ["127.0.0.1"]' >> apache-storm-1.0.3/conf/storm.yaml
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

Once everything is up without errors, visit [http://localhost:8080](http://localhost:8080) and see if the Storm UI loads.

#### Step 4: Test Storm (Optional)

Before Bullet, test to see if Storm and DRPC are up and running by launching a example topology that comes with your Storm installation:

```bash
storm jar apache-storm-1.0.3/examples/storm-starter/storm-starter-topologies-1.0.3.jar org.apache.storm.starter.BasicDRPCTopology topology
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

## Setting up the example Bullet topology

Now that Storm is up and running, we can put Bullet on it. We will use an example Spout that runs on Bullet 0.3.1 on our Storm cluster. The source is available [here](https://github.com/yahoo/bullet-docs/blob/master/examples/storm). This was part of the artifact that you installed in Step 1.

#### Step 5: Setup the Storm example

```bash
cp $BULLET_EXAMPLES/storm/* $BULLET_HOME/backend/storm
```

!!! note "Settings"

    Take a look at bullet_settings.yaml for the settings that are being overridden for this example. You can add or change settings as you like by referring to [bullet_defaults.yaml](https://github.com/yahoo/bullet-storm/blob/master/src/main/resources/bullet_defaults.yaml). In particular, we have [customized these settings](https://github.com/yahoo/bullet-docs/blob/master/examples/storm/src/main/resources/bullet_settings.yaml) that affect the Bullet queries you can run:

    ```bullet.rule.max.duration: 570000``` Longest query time can be 570s. The Storm cluster default DRPC timeout is 600s.

    ```bullet.rule.aggregation.raw.max.size: 500``` The max ```RAW``` records you can fetch is 500.

    ```bullet.rule.aggregation.max.size: 1024``` The max records you can fetch for any query is 1024.

    ```bullet.rule.aggregation.count.distinct.sketch.entries: 16384``` We can count 16384 unique values exactly. Approximates after.

    ```bullet.rule.aggregation.group.sketch.entries: 1024``` The max unique groups can be 1024. Uniform sample after.

!!! note "Want to tweak the example topology code?"

    You will need to clone the [examples repository](https://github.com/yahoo/bullet-docs/tree/master/examples/storm) and customize it. To build the examples, you'll need to install [Maven 3](https://maven.apache.org/install.html).

    ```cd $BULLET_HOME && git clone git@github.com:yahoo/bullet-docs.git```

    ```cd bullet-docs/examples/storm && mvn package```

    You will find the ```bullet-storm-example-1.0-SNAPSHOT-jar-with-dependencies.jar``` in ```$BULLET_HOME/bullet-docs/examples/storm/target/```

#### Step 6: Launch the topology

```bash
cd $BULLET_HOME/backend/storm && ./launch.sh
```
This script also kills any existing Bullet instances running (you may see an ignorable exception if there is nothing running). There can only be one topology in the cluster with a particular name. Visit the UI and see if the topology is up. You should see the ```DataSource``` spout begin emitting records.

Test the Bullet topology by:

```bash
curl -s -X POST -d '{}' http://localhost:3774/drpc/bullet
```

You should get a random record from Bullet.

!!! note "What is this data?"

    This data is randomly generated by the [custom Storm spout](https://github.com/yahoo/bullet-docs/blob/master/examples/storm/src/main/java/com/yahoo/bullet/storm/examples/RandomSpout.java) that is in the example topology you just launched. In practice, your spout would read from an actual data source such as Kafka instead. See [below](#storm-topology) for more details about this random data spout.

## Setting up the Bullet Web Service

#### Step 7: Install Jetty

```bash
cd $BULLET_HOME/service
curl -O http://central.maven.org/maven2/org/eclipse/jetty/jetty-distribution/9.3.16.v20170120/jetty-distribution-9.3.16.v20170120.zip
unzip jetty-distribution-9.3.16.v20170120.zip
```

#### Step 8: Install the Bullet Web Service

```bash
cd jetty-distribution-9.3.16.v20170120
curl -Lo webapps/bullet-service.war http://jcenter.bintray.com/com/yahoo/bullet/bullet-service/0.0.1/bullet-service-0.0.1.war
cp $BULLET_EXAMPLES/web-service/example_* $BULLET_HOME/service/jetty-distribution-9.3.16.v20170120
```

#### Step 9: Launch the Web Service

```bash
cd $BULLET_HOME/service/jetty-distribution-9.3.16.v20170120
java -jar -Dbullet.service.configuration.file="example_context.properties" -Djetty.http.port=9999 start.jar > logs/out 2>&1 &
```
You can verify that it is up by running the Bullet query and getting the example columns through the API:

```bash
curl -s -X POST -d '{}' http://localhost:9999/bullet-service/api/drpc
curl -s http://localhost:9999/bullet-service/api/columns
```

## Setting up the Bullet UI

#### Step 10: Install Node

```bash
curl -s https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash
source ~/.bashrc
nvm install v6.9.4
nvm use v6.9.4
```

#### Step 11: Install the Bullet UI

```bash
cd $BULLET_HOME/ui
curl -LO https://github.com/yahoo/bullet-ui/releases/download/v0.1.0/bullet-ui-v0.1.0.tar.gz
tar -xzf bullet-ui-v0.1.0.tar.gz
cp $BULLET_EXAMPLES/ui/env-settings.json config/
```

#### Step 12: Launch the UI

```bash
PORT=8800 node express-server.js &
```

Visit [http://localhost:8800](http://localhost:8800) to query your topology with the UI. See [UI usage](ui/usage.md) for some example queries and interactions using this UI. You see what the Schema means by visiting the Schema section.

!!! note "Running it remotely?"

    If you access the UI from another machine than where your UI is actually running, you will need to edit ```config/env-settings.json```. Since the UI is a client-side app, the machine that your browser is running on will fetch the UI and attempt to use these settings to talk to the Web Service. Since they point to localhost by default, your browser will attempt to connect there and fail. An easy fix is to change ```localhost``` in your env-settings.json to point to the host name where you will hosting the UI. This will be the same as the UI host you use in the browser.


## Teardown

To cleanup all the components we bought up:

|                |                                                                                     |
| -------------- | ----------------------------------------------------------------------------------- |
| UI             | ```ps aux | grep [e]xpress-server.js | awk '{print $2}' | xargs kill```             |
| Web Service    | ```ps aux | grep [e]xample_context.properties | awk '{print $2}' | xargs kill```    |
| Storm          | ```ps aux | grep [a]pache-storm-1.0.3 | awk '{print $2}' | xargs kill```            |
| File System    | ```rm -rf $BULLET_HOME /tmp/dev-storm-zookeeper /tmp/jetty-*```                     |

You can also do:
```bash
curl -sLo- https://raw.githubusercontent.com/yahoo/bullet-docs/v0.1.2/examples/install-all.sh | bash -s cleanup
```

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

### Web Service

We launched the Web Service using two custom files - a properties file and JSON schema file.

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
The [example properties file](https://github.com/yahoo/bullet-docs/blob/master/examples/web-service/example_context.properties) points to the DRPC host, port, and path as well points to the custom columns file.

```
drpc.servers=localhost
drpc.port=3774
drpc.path=drpc/bullet
drpc.retry.limit=3
drpc.connect.timeout=1000
columns.file=example_columns.json
columns.schema.version=1.0
```

```drpc.servers``` is a CSV entry that contains the various DRPC servers in your Storm cluster. If you [visit the Storm UI](http://localhost:8080) and search in the ```Nimbus Configuration``` section, you can find the list of DRPC servers for your cluster. Similarly, ```drpc.port``` in the properties file is ```drpc.http.port``` in ```Nimbus Configuration```. The ```drpc.path``` is the constant string ```drpc/``` followed by the value of the ```topology.function``` setting in bullet_settings.yaml.


### UI

Finally, we configured the UI with the custom environment specific settings file. We did not add any environments since we only had the one.

```javascript
{
  "default": {
    "drpcHost": "http://localhost:9999",
    "drpcNamespace": "bullet-service/api",
    "drpcPath": "drpc",
    "schemaHost": "http://localhost:9999",
    "schemaNamespace": "bullet-service/api",
    "helpLinks": [
      {
        "name": "Example Docs Page",
        "link": ""
      }
    ],
    "bugLink": "https://github.com/yahoo/bullet-ui/issues",
    "aggregateDataDefaultSize": 1024,
    "modelVersion": 1
  }
}
```

Since we served our schema through the same Web Service as our queries, both these point to our Web Service. Note that there is no ```schemaPath``` because it must be the constant string ```columns```. If you define a custom endpoint for your schema, you must ensure that it can be obtained by making a GET request to ```schemaHost/schemaNamespace/columns```.

The [UI Usage](ui/usage.md) page shows you some queries you can run using one such instance of the UI.
