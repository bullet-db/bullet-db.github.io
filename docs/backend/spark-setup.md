# Bullet on Spark

This section explains how to set up and run Bullet on Spark.

## Configuration

Bullet is configured at run-time using settings defined in a file. Settings not overridden will default to the values in [bullet_spark_defaults.yaml](https://github.com/bullet-db/bullet-spark/blob/master/src/main/resources/bullet_spark_defaults.yaml). You can find out what these settings do in the comments listed in the defaults.

## Installation

Download Bullet Spark standalone jar from [JCenter](http://jcenter.bintray.com/com/yahoo/bullet/bullet-spark/).

## Implementation

To use Bullet Spark, you need to implement your own data producer with a JVM based project. You have two ways to implement it as described at [Spark Architecture](spark-architecture.md#data-processing). You include the Bullet artifact and Spark dependencies in your pom.xml or other equivalent config files. The artifacts are available through JCenter. Here is an example if you use Scala and Maven:

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
    <bullet.spark.version>0.1.0</bullet.spark.version>
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

## Launch

After you have implemented your own data producer and built a jar, you could launch your Bullet Spark. Here is an example command for [YARN cluster](https://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/YARN.html).

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
    ... # other spark streaming configurations
    --jars path/to/your-data-producer.jar \
    path/to/downloaded-bullet-spark-standalone.jar \
    --bullet-spark-conf /path/to/your-settings.yaml
```

You can pass other spark streaming configurations by adding ```--conf key=value``` to the command. For more configurations, you can refer [Spark Configuration](https://spark.apache.org/docs/latest/configuration.html).

For other platforms, you could find the commands from [Spark Docs](https://spark.apache.org/docs/latest/submitting-applications.html).