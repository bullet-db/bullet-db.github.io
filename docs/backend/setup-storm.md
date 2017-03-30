# Bullet on Storm

## Storm DRPC

Bullet on [Storm](https://storm.apache.org/) is built using [Storm DRPC](http://storm.apache.org/releases/1.0.0/Distributed-RPC.html). DRPC comes with Storm installations and generally consist of a set of DRPC servers. When a Storm topology is launched and it uses DRPC, it registers a spout with a unique name with the DRPC infrastructure. The DRPC Servers expose a REST endpoint where data can be POSTed to or a GET request can be made with this unique name. The DRPC infrastructure then sends the request (a query in Bullet) through the spout(s) to the topology (Bullet). Bullet uses the query to filter and joins all records emitted from your (configurable) data source - either a Spout or a topology component according to the query specification. The resulting matched records are aggregated and sent back to the client. We chose to implement Bullet on Storm first since DRPC provides us a nice and simple way to handle getting queries into Bullet and sending responses back.

### Query duration in Storm DRPC

The maximum time a query can run for depends on the maximum time Storm DRPC request can last in your Storm topology. Generally the default is set to 10 minutes. This means that the **longest query duration possible will be 10 minutes**. This is up to your cluster maintainers.

## Configuration

Bullet is configured at run-time using settings defined in a file. Settings not overridden will default to the values in [bullet_defaults.yaml](https://github.com/yahoo/bullet-storm/blob/master/src/main/resources/bullet_defaults.yaml). There are too many to list here. You can find out what these settings do in the comments listed in the defaults.

## Installation

To use Bullet, you need to implement a way to read from your data source and convert your data into Bullet Records (bullet-record is a transitive dependency for Bullet and can be found [in JCenter](ingestion.md#installing-the-record-directly). You have two options in how to get your data into Bullet:

1. You can implement a Spout that reads from your data source and emits Bullet Record. This spout must have a constructor that takes a List of Strings.
2. You can pipe your existing Storm topology directly into Bullet. In other words, you convert the data you wish to be query-able through Bullet into Bullet Records from a bolt in your topology.

Option 1 is the simplest to start with and should accommodate most scenarios. See [Pros and Cons](storm-architecture.md#data-processing).

You need a JVM based project that implements one of the two options above. You include the Bullet artifact and Storm dependencies in your pom.xml or other dependency management system. The artifacts are available through JCenter, so you will need to add the repository.

```xml
<repositories>
    <repository>
        <snapshots>
            <enabled>false</enabled>
        </snapshots>
        <id>central</id>
        <name>bintray</name>
        <url>http://jcenter.bintray.com</url>
    </repository>
</repositories>
```

```xml
<dependency>
  <groupId>org.apache.storm</groupId>
  <artifactId>storm-core</artifactId>
  <version>${storm.version}</version>
  <scope>provided</scope>
</dependency>

<dependency>
  <groupId>com.yahoo.bullet</groupId>
  <artifactId>bullet-storm</artifactId>
  <version>${bullet.version}</version>
</dependency>
```

If you just need the jar artifact directly, you can download it from [JCenter](http://jcenter.bintray.com/com/yahoo/bullet/bullet-storm/).

You can also add ```<classifier>sources</classifier>```  or ```<classifier>javadoc</classifier>``` if you want the sources or javadoc. We also package up our test code where we have some helper classes to deal with [Storm components](https://github.com/yahoo/bullet-storm/tree/master/src/test/java/com/yahoo/bullet/storm). If you wish to use these to help with testing your topology, you can add another dependency on bullet-storm with ```<type>test-jar</type>```.

If you are going to use the second option (directly pipe data into Bullet from your Storm topology), then you will need a main class that directly calls the submit method with your wired up topology and the name of the component that is going to emit Bullet Records in that wired up topology. The submit method can be found in [Topology.java](https://github.com/yahoo/bullet-storm/blob/master/src/main/java/com/yahoo/bullet/Topology.java). The submit method submits the topology so it should be the last thing you do in your main.

If you are just implementing a Spout, see the [Launch](#launch) section below on how to use the main class in Bullet to create and submit your topology.

Storm topologies are generally launched with "fat" jars (jar-with-dependencies), excluding storm itself:

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-assembly-plugin</artifactId>
    <version>2.4</version>
    <executions>
        <execution>
            <id>assemble-all</id>
            <phase>package</phase>
            <goals>
                <goal>single</goal>
            </goals>
        </execution>
    </executions>
    <configuration>
        <descriptorRefs>
            <descriptorRef>jar-with-dependencies</descriptorRef>
        </descriptorRefs>
    </configuration>
</plugin>
```

### Older Storm Versions

Since package prefixes changed from `backtype.storm` to `org.apache.storm` in Storm 1.0 and above, you will need to get the storm-0.10 version of Bullet if
your Storm cluster is still not at 1.0 or higher. You change your dependency to:

```xml
<dependency>
    <groupId>com.yahoo.bullet</groupId>
    <artifactId>bullet-storm-0.10</artifactId>
    <version>${bullet.version}</version>
</dependency>
```

The jar artifact can be downloaded directly from [JCenter](http://jcenter.bintray.com/com/yahoo/bullet/bullet-storm-0.10/).

You can also add ```<classifier>sources</classifier>```  or ```<classifier>javadoc</classifier>``` if you want the source or javadoc and ```<type>test-jar</type>``` for the test classes as with bullet-storm.

Also, since storm-metrics and the Resource Aware Scheduler are not in Storm versions less than 1.0, there are changes in the Bullet settings. The settings that set the CPU and memory loads do not exist (so the config file does not specify them). The setting to enable the topology scheduler are no longer present (you can still override these settings if you run a custom version of Storm by passing it to the storm jar command. [See below](#launch).) You can take a look the settings file on the storm-0.10 branch in the Git repo.

If for some reason, you are running a version of Storm less than 1.0 that has the RAS back-ported to it and you wish to set the CPU and other settings, you will your own main class that mirrors the master branch of the main class but with backtype.storm packages instead.

## Launch

If you have implemented your own main class (option 2 above), you just pass your main class to the storm executable as usual. If you are implementing a spout, here's an example of how you could launch the topology:

```bash
storm jar your-fat-jar-with-dependencies.jar \
          com.yahoo.bullet.Topology \
          --bullet-conf path/to/the/bullet_settings.yaml \
          --bullet-spout full.package.prefix.to.your.spout.implementation \
          --bullet-spout-parallelism 64 \
          --bullet-spout-cpu-load 200.0 \
          --bullet-spout-on-heap-memory-load 512.0 \
          --bullet-spout-off-heap-memory-load 256.0 \
          --bullet-spout-arg arg-to-your-spout-class-for-ex-a-path-to-a-config-file \
          --bullet-spout-arg another-arg-to-your-spout-class \
          -c topology.acker.executors=64 \
          -c topology.max.spout.pending=10000
```

You can pass other arguments to Storm using the -c argument. The example above uses 64 ackers, which is the parallelism of the Filter Bolt. Storm DRPC follows the principle of leaving retries to the DRPC user (in our case, the Bullet web service). As a result, most of the DRPC components do not follow any at least once guarantees. However, you can enable at least once for the hop from your topology (or spout) to the Filter Bolt. This is why this example uses the parallelism of the Filter Bolt as the number of ackers since that is exactly the number of acker tasks we would need (not accounting for the DRPCSpout to the PrepareRequest Bolt acking). Ackers are lightweight so you need not have the same number of tasks as Filter Bolts but you can tweak it accordingly. The example above also sets max spout pending to control how fast the spout emits. You could use the back-pressure mechanisms in Storm in addition or in lieu of as you choose. We have found that max spout pending gives a much more predictable way of throttling our spouts during catch up or data spikes.

!!! note "Main Class Arguments"

    If you run the main class without arguments or pass in the ```--help``` argument, you can see what these arguments mean and what others are supported.

## Test

Once the topology is up and your data consumption has stabilized, you could post a query to a DRPC server in your cluster. Try a simple query from the [examples](../ws/examples.md#simplest-query) by running a curl from a command line:

```bash
curl -s -X POST -d '{}' http://<DRPC_HOST>:<DRPC_PORT>/drpc/<YOUR_TOPOLOGY_FUNCTION_FROM_YOUR_BULLET_CONF>
```

You should receive a random record flowing through Bullet instantly (if you left the Raw aggregation micro-batch size at the default of 1).
