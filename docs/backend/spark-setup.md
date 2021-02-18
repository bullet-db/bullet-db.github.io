# Bullet on Spark

This section explains how to set up and run Bullet on Spark.

## Configuration

Bullet is configured at run-time using settings defined in a file. Settings not overridden will default to the values in [bullet_spark_defaults.yaml](https://github.com/bullet-db/bullet-spark/blob/master/src/main/resources/bullet_spark_defaults.yaml). You can find out what these settings do in the comments listed in the defaults.

## Installation

Download the Bullet Spark standalone jar from [JCenter](http://jcenter.bintray.com/com/yahoo/bullet/bullet-spark/).

If you are using Bullet Kafka as pluggable PubSub, you can download the fat jar from [JCenter](http://jcenter.bintray.com/com/yahoo/bullet/bullet-kafka/). Otherwise, you need to plug in your own PubSub jar or use the RESTPubSub built-into bullet-core and turned on in the API.

To use Bullet Spark, you need to implement your own [Data Producer Trait](https://github.com/bullet-db/bullet-spark/blob/master/src/main/scala/com/yahoo/bullet/spark/DataProducer.scala) with a JVM based project or you can use Bullet DSL (see below). If you choose to implement your own, you have two ways as described in the [Spark Architecture](spark-architecture.md#data-processing) section. You include the Bullet artifact and Spark dependencies in your pom.xml or other equivalent build tools. The artifacts are available through JCenter. Here is an example if you use Scala and Maven:

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
<properties>
    <scala.version>2.11.7</scala.version>
    <scala.dep.version>2.11</scala.dep.version>
    <spark.version>2.3.0</spark.version>
    <bullet.spark.version>0.1.1</bullet.spark.version>
</properties>

<dependency>
    <groupId>org.scala-lang</groupId>
    <artifactId>scala-library</artifactId>
    <version>${scala.version}</version>
    <scope>provided</scope>
</dependency>

<dependency>
    <groupId>org.apache.spark</groupId>
    <artifactId>spark-streaming_${scala.dep.version}</artifactId>
    <version>${spark.version}</version>
    <scope>provided</scope>
</dependency>

<dependency>
    <groupId>org.apache.spark</groupId>
    <artifactId>spark-core_${scala.dep.version}</artifactId>
    <version>${spark.version}</version>
    <scope>provided</scope>
</dependency>

<dependency>
     <groupId>com.yahoo.bullet</groupId>
     <artifactId>bullet-spark</artifactId>
     <version>${bullet.spark.version}</version>
</dependency>
```

You can also add ```<classifier>sources</classifier>``` or ```<classifier>javadoc</classifier>``` if you want the sources or javadoc.

### Using Bullet DSL

Instead of implementing your own Data Producer, you can also use the provided DSL receiver with [Bullet DSL](dsl.md). To do so, add the following settings to your YAML configuration:

```yaml
# If true, enables the Bullet DSL data producer which can be configured to read from a custom data source. If enabled,
# the DSL data producer is used instead of the producer.
bullet.spark.dsl.data.producer.enable: true

# If true, enables the deserializer between the Bullet DSL connector and converter components. Otherwise, this step is skipped.
bullet.spark.dsl.deserializer.enable: false
```

You may then use the appropriate DSL settings to point to the class names of the Connector and Converter you wish to use to read from your data source and convert it to BulletRecord instances.

There is also a setting to enable [BulletDeserializer](dsl.md#bulletdeserializer), which is an optional component of Bullet DSL for deserializing data between reading and converting.  

## Launch

After you have implemented your own data producer or used Bullet DSL and built a jar, you could launch your Bullet Spark application. Here is an example command for a [YARN cluster](https://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/YARN.html).

```bash
./bin/spark-submit \
    --master yarn \
    --deploy-mode cluster \
    --class com.yahoo.bullet.spark.BulletSparkStreamingMain \
    --queue <your queue> \
    --executor-memory 12g \
    --executor-cores 2 \
    --num-executors 200 \
    --driver-cores 2 \
    --driver-memory 12g \
    --conf spark.streaming.backpressure.enabled=true \
    --conf spark.default.parallelism=20 \
    ... # other Spark settings
    --jars /path/to/your-data-producer.jar,/path/to/your-pubsub.jar \
    /path/to/downloaded-bullet-spark-standalone.jar \
    --bullet-spark-conf /path/to/your-settings.yaml
```

You can pass other Spark settings by adding ```--conf key=value``` to the command. For more settings, you can refer to the [Spark Configuration](https://spark.apache.org/docs/latest/configuration.html).

For other platforms, you can find the commands from the [Spark Documentation](https://spark.apache.org/docs/latest/submitting-applications.html).
