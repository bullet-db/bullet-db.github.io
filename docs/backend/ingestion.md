# Data Ingestion

Bullet operates on a generic data container that it understands. In order to get Bullet to operate on your data, you need to convert your data records into this format. This conversion is usually done when you plug in your data source into Bullet. Bullet does not make any assumptions on where you get this data from. It could be [Kafka](http://kafka.apache.org), [RabbitMQ](https://www.rabbitmq.com/), or something else.

!!!note "If you are trying to set up Bullet..."

    The rest of this page gives more information about the Record container and how to depend on it in code directly. If you are setting up Bullet, the Record is already included by default with the Bullet artifact. You can head on over to [setting up the Storm topology](setup-storm.md#installation) to build the piece that gets your data into the Record container.

## Bullet Record

The Bullet Record is a serializable data container based on [Avro](http://avro.apache.org). It is typed and has a generic schema. You can refer to the [Avro Schema](https://github.com/yahoo/bullet-record/blob/master/src/main/avro/BulletAvro.avsc) file for details if you wish to see the internals of the data model. The Bullet Record is also lazy and only deserializes itself when you try to read something from it. So, you can pass it around before sending to Bullet with minimal cost. Partial deserialization is being considered if performance is key. This will let you deserialize a much narrower chunk of the Record if you are just looking for a couple of fields.

## Types

Data placed into a Bullet Record is strongly typed. We support these types currently:

### Primitives

1. Boolean
2. Long
3. Double
4. String

### Complex

1. Map of Strings to any of the [Primitives](#primitives)
2. Map of Strings to any Map in 1
3. List of any Map in 1

With these types, it is unlikely you would have data that cannot be represented as Bullet Record but if you do, please let us know and we are more than willing to accommodate.

## Installing the Record directly

Generally, you depend on the Bullet artifact for your Stream Processor when you plug in the piece that gets your data into the Stream processor. The Bullet artifact already brings in the Bullet Record container as well. See the usage for the [Storm](setup-storm.md#installation).

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
