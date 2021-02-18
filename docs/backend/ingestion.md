# Data Ingestion

Bullet operates on a generic data container that it understands. In order to get Bullet to operate on your data, you need to convert your data records into this format. This conversion is usually done when you plug in your data source into Bullet. Bullet does not make any assumptions on where you get this data from. It could be [Kafka](http://kafka.apache.org), [RabbitMQ](https://www.rabbitmq.com/), or something else.

!!!note "If you are trying to set up Bullet..."

    The rest of this page gives more information about the Record container and how to depend on it in code directly. If you are setting up Bullet, the Record is already included by default with the Bullet artifact. You can head on over to [setting up the Storm topology](storm-setup.md#installation) to build the piece that gets your data into the Record container.

## Bullet Record

The Bullet backend processes data that must be stored in a [Bullet Record](https://github.com/bullet-db/bullet-record/blob/master/src/main/java/com/yahoo/bullet/record/BulletRecord.java) which is an abstract Java class that can
be implemented as to be optimized for different backends or use-cases.

There are currently two concrete implementations of BulletRecord:

1. [SimpleBulletRecord](https://github.com/bullet-db/bullet-record/blob/master/src/main/java/com/yahoo/bullet/record/SimpleBulletRecord.java) which is based on a simple Java HashMap
2. [AvroBulletRecord](https://github.com/bullet-db/bullet-record/blob/master/src/main/java/com/yahoo/bullet/record/AvroBulletRecord.java) which uses [Avro](http://avro.apache.org) for serialization

## Types

Data placed into a Bullet Record is strongly typed. We support these types currently:

### Primitives

1. Boolean
2. Integer
3. Long
4. Float
5. Double
6. String

### Complex

1. Map of Strings to any of the [Primitives](#primitives)
2. Map of Strings to any Map in 1
3. List of any of the [Primitives](#primitives)
3. List of any Map in 1

With these types, it is unlikely you would have data that cannot be represented as Bullet Record but if you do, please let us know and we are more than willing to accommodate.

## Installing the Record directly

Generally, you depend on the Bullet Core artifact for your Stream Processor when you plug in the piece that gets your data into the Stream processor. The Bullet Core artifact already brings in the Bullet Record containers as well. See the usage for the [Storm](storm-setup.md#installation) for an example.

However, if you need it, the artifacts are available through JCenter to depend on them in code directly. You will need to add the repository. Below is a Maven example:

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
  <groupId>com.yahoo.bullet</groupId>
  <artifactId>bullet-record</artifactId>
  <version>${bullet.version}</version>
</dependency>
```

If you just need the jar artifact, you can download it directly from [JCenter](http://jcenter.bintray.com/com/yahoo/bullet/bullet-record/).

You can also add ```<classifier>sources</classifier>```  or ```<classifier>javadoc</classifier>``` if you want the sources or the javadoc.
