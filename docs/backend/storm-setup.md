# Bullet on Storm

This section explains how to set up and run Bullet on Storm. If you're using the Storm DRPC PubSub, refer to [this section](../pubsub/storm-drpc.md) for further details.

## Configuration

Bullet is configured at run-time using settings defined in a file. Settings not overridden will default to the values in [bullet_defaults.yaml](https://github.com/bullet-db/bullet-storm/blob/master/src/main/resources/bullet_defaults.yaml). There are too many to list here. You can find out what these settings do in the comments listed in the defaults.

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

You can also add ```<classifier>sources</classifier>```  or ```<classifier>javadoc</classifier>``` if you want the sources or javadoc. We also package up our test code where we have some helper classes to deal with [Storm components](https://github.com/bullet-db/bullet-storm/tree/master/src/test/java/com/yahoo/bullet/storm). If you wish to use these to help with testing your topology, you can add another dependency on bullet-storm with ```<type>test-jar</type>```.

If you are going to use the second option (directly pipe data into Bullet from your Storm topology), then you will need a main class that directly calls the submit method with your wired up topology and the name of the component that is going to emit Bullet Records in that wired up topology. The submit method can be found in [Topology.java](https://github.com/bulletbullet-storm/blob/master/src/main/java/com/yahoo/bullet/Topology.java). The submit method submits the topology so it should be the last thing you do in your main.

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
          -c topology.acker.executors=64 \
          -c topology.max.spout.pending=10000
```

And in your bullet_settings.yaml, you would have, for example:

```yaml
bullet.topology.bullet.spout.class.name: "full.package.prefix.to.your.spout.implementation"
bullet.topology.bullet.spout.args: ["arg-to-your-spout-class-for-example-a-path-to-a-config-file", "another-arg-to-your-spout-class"]
bullet.topology.bullet.spout.parallelism: 64
bullet.topology.bullet.spout.cpu.load: 200.0
bullet.topology.bullet.spout.memory.on.heap.load: 512.0
bullet.topology.bullet.spout.memory.off.heap.load: 256.0
```

You can pass other arguments to Storm using the -c argument. The example above uses 64 ackers, for example and uses Storm's [reliable message processing mechanisms](http://storm.apache.org/releases/1.1.0/Guaranteeing-message-processing.html). Certain components in the Bullet Storm topology cannot be reliable due to how Bullet operates currently. Hundreds of millions of Storm tuples could go into any query running in Bullet and it is intractable to *anchor* a single Bullet aggregation to those tuples, particularly when the results are approximate. However, you should enable acking to ensure at least once message deliveries for the hop from your topology (or spout) to the Filter bolts and for the Query spouts to the Filter and Join bolts. Ackers are lightweight so you need not have the same number of tasks as components that ack in your topology so you can tweak it accordingly. The example above also sets max spout pending to control how fast the spout emits. You could use the back-pressure mechanisms in Storm in addition or in lieu of as you choose. We have found that max spout pending gives a much more predictable way of throttling our spouts during catch up or data spikes.

!!! note "Main Class Arguments"

    If you run the main class without arguments or pass in the ```--help``` argument, you can see what these arguments mean and what others are supported.

### Using Bullet DSL

Instead of implementing your own spout, you can also use the provided DSL Spout (and optionally, DSL Bolt) with [Bullet DSL]().

To do so, you would add the following settings to your YAML configuration:

```yaml
bullet.topology.dsl.spout.enable: true
bullet.topology.dsl.spout.parallelism: 
bullet.topology.dsl.spout.cpu.load: 
bullet.topology.dsl.spout.memory.on.heap.load: 
bullet.topology.dsl.spout.memory.off.heap.load: 

bullet.topology.dsl.bolt.enable: false
bullet.topology.dsl.bolt.parallelism:
bullet.topology.dsl.bolt.cpu.load:
bullet.topology.dsl.bolt.memory.on.heap.load:
bullet.topology.dsl.bolt.memory.off.heap.load:

bullet.topology.dsl.deserializer.enable: false
```

If the DSL Bolt is enabled in addition to the spout (the spout is required!), Storm will read your data in the spout and convert it in the bolt. Without the bolt, reading and converting are done entirely in the spout. By enabling the DSL Bolt, you can lower per-worker latencies when data volume is large.

Note that there is also a setting to enable [BulletDeserializer]() which is an optional component of Bullet DSL for deserializing data between reading and converting.  

#### Setup

The Bullet Storm jar is not built with Bullet DSL or with other dependencies you may want such as Kafka and Pulsar. 
Instead, you will have to either add the dependencies to the Storm launcher and worker environments or build a fat jar with the dependencies.
In Storm 1.2.2+, however, you also have the option of directly adding the jars to the classpath in the "storm jar" command. 

Kafka dependencies:

[https://bintray.com/bintray/jcenter/org.apache.kafka%3Akafka-clients](kafka-clients) 2.1.0

Pulsar dependencies:

[https://bintray.com/bintray/jcenter/org.apache.pulsar%3Apulsar-client](pulsar-client) 2.2.1

[https://bintray.com/bintray/jcenter/org.apache.pulsar%3Apulsar-client-schema](pulsar-client-schema) 2.2.1

[https://bintray.com/bintray/jcenter/org.apache.pulsar%3Aprotobuf-shaded](protobuf-shaded) 2.1.0-incubating

Storm 1.2.2 example for Pulsar:

```
storm jar bullet-storm-0.9.1.jar \
          com.yahoo.bullet.storm.Topology \
          --bullet-conf ./bullet_settings.yaml \
          --jars "bullet-dsl-0.1.2.jar,pulsar-client-2.2.1.jar,pulsar-client-schema-2.2.1.jar,protobuf-shaded-2.1.0-incubating.jar"
```
