# Bullet DSL






Bullet DSL is a configuration-based DSL that allows users to plug their data into the Bullet Backend. What this means is that users do not have to write code to ingest data but can instead provide
YAML configuration. 



Bullet DSL is a configuration-based DSL that allows users to plug their data into the Bullet Backend.

Originally, users had to write their own code to ingest data, but now users only have to provide YAML configuration.



This is really great for users because unlike before, where users had to write their own code to ingest data, now, users only have to provide the appropriate YAML configuration.

This is really great for users because it allows them to get around writing code to ingest data.




Bullet DSL provides two major components. The first is for reading data from a pluggable data source, and the second is for converting data into [BulletRecords](ingestion.md)

Bullet DSL can be enabled in the Bullet Backends, and by configuring Bullet DSL accordingly, the backend will read from the configured data source and convert any read-in data into BulletRecords.




There are three main things to configure: the BulletConnector (Bullet DSL's reading component), the BulletRecordConverter (Bullet DSL's converting component), and the Backend.

!!!note

    For the Backend, please refer to the DSL-specific Bullet Storm setup [here](). (Currently, only Bullet Storm supports Bullet DSL.)



## BulletConnector

BulletConnector is an abstract Java class that can be implemented to read data from different pluggable data sources. 

Currently, we support two BulletConnector implementations:

1. [KafkaConnector](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/connector/KafkaConnector.java) for [Apache Kafka]
2. [PulsarConnector](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/connector/PulsarConnector.java) for [Apache Pulsar]


For Bullet DSL, you will need to specify the BulletConnector to use. For example, to use KafkaConnector, you would add the following to your configuration file:

```yaml
# The classpath to the BulletConnector to use (need this for Bullet DSL!)
bullet.dsl.connector.class.name: "com.yahoo.bullet.dsl.connector.KafkaConnector"

# The read timeout duration in ms (defaults to 0)
bullet.dsl.connector.read.timeout.ms: 0

# Whether or not to asynchronously commit messages (defaults to true)
bullet.dsl.connector.async.commit.enable: true
```

All configuration can be found in the [default configuration file](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/resources/bullet_dsl_defaults.yaml) along with specific configuration for each implementation.

!!!note "Title of box"

    If you have a different kind of data source, """you will have to implement your own BulletConnector""". We will be implementing more connectors in the future. If you write your own connector, you can also help contribute! Instructions/class file


### KafkaConnector

The KafkaConnector configuration requires a few settings that are necessary to read from Kafka.

Specifically, the Kafka Consumer requires the bootstrap servers, group id, and key/value deserializers, and the connector requires the topics to subscribe to. 

```yaml
# The list of Kafka topics to subscribe to (required)
bullet.dsl.connector.kafka.topics:
- ""

# Whether or not the KafkaConsumer should seek to the end of its subscribed topics at initialization (defaults to false)
bullet.dsl.connector.kafka.start.at.end.enable: false

# Required consumer properties
bullet.dsl.connector.kafka.bootstrap.servers: "localhost:9092"
bullet.dsl.connector.kafka.group.id:
bullet.dsl.connector.kafka.key.deserializer: "org.apache.kafka.common.serialization.StringDeserializer"
bullet.dsl.connector.kafka.value.deserializer:
```

You can also pass additional Kafka properties to the KafkaConnector by prefixing them with ```bullet.dsl.connector.kafka.``` For a complete list of properties, see the [Kafka Consumer configs](https://kafka.apache.org/0102/documentation.html#newconsumerconfigs).

### PulsarConnector

[need to revise]

The PulsarConnector configuration requires a few settings that are necessary to read from Pulsar, and it also provides the option to enable authentication.

The client requires the service url, and the consumer requires the subscription name and subscription type. 

The connector requires the topics to subscribe to. 

The connector requires the schema type for Pulsar. (It can be BYTES, STRING, JSON, AVRO, PROTOBUF, or CUSTOM)

If it's JSON, AVRO, or PROTOBUF, it also requires the POJO class to wrap.

If it's CUSTOM, it requires the custom schema class. 

```yaml
# The list of Pulsar topics to subscribe to (required)
bullet.dsl.connector.pulsar.topics:
- ""

# The Pulsar Schema to use (required)
bullet.dsl.connector.pulsar.schema.type: "BYTES"

# The classpath to the Pulsar Schema to use (required only if using JSON, AVRO, PROTOBUF, or CUSTOM schema)
bullet.dsl.connector.pulsar.schema.class.name:

# Required client property
bullet.dsl.connector.pulsar.client.serviceUrl: "pulsar://localhost:6650"

# Authentication properties (disabled by default)
bullet.dsl.connector.pulsar.auth.enable: false
bullet.dsl.connector.pulsar.auth.plugin.class.name:
bullet.dsl.connector.pulsar.auth.plugin.params.string:

# Required consumer properties
bullet.dsl.connector.pulsar.consumer.subscriptionName: ""
bullet.dsl.connector.pulsar.consumer.subscriptionType: "Shared"
```

You can also pass additional Pulsar Client and Consumer properties to the PulsarConnector by prefixing them with ```bullet.dsl.connector.pulsar.client``` and ```bullet.dsl.connector.pulsar.consumer``` For the lists of properties, see Pulsar [ClientConfigurationData](https://github.com/apache/pulsar/blob/master/pulsar-client/src/main/java/org/apache/pulsar/client/impl/conf/ClientConfigurationData.java) and [ConsumerConfigurationData](https://github.com/apache/pulsar/blob/master/pulsar-client/src/main/java/org/apache/pulsar/client/impl/conf/ConsumerConfigurationData.java).

## BulletRecordConverter

BulletRecordConverter is an abstract Java class that can be implemented to convert different types of data into BulletRecords.

Currently, we support three BulletRecordConverter implementations:

1. [POJOBulletRecordConverter](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/converter/POJOBulletRecordConverter.java) (POJOs)
2. [MapBulletRecordConverter](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/converter/MapBulletRecordConverter.java) (Java Maps)
3. [AvroBulletRecordConverter](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/converter/AvroBulletRecordConverter.java) (Apache Avro Records)

These converters support converting [POJOs](https://en.wikipedia.org/wiki/Plain_old_Java_object), Java Maps, and [Apache Avro](https://avro.apache.org/) records to BulletRecords.

For Bullet DSL, you will need to specify the BulletRecordConverter to use. For example, to use AvroBulletRecordConverter, you would add the following to your configuration file:

```yaml
# The classpath to the BulletRecordConverter to use
bullet.dsl.converter.class.name: "com.yahoo.bullet.dsl.converter.AvroBulletRecordConverter"

# The path to the schema file to use
bullet.dsl.converter.schema.file: "your-schema-file.json"
```

Note, while a schema is not required, there are some [benefits]() to using one. 

!!!note

    Unfortunately, we don't have other converters, but this should cover most use cases. If you do need a specific converter though, you can write your own. Instructions/class file. You can also help contribute.

### POJOBulletRecordConverter

POJOBulletRecordConverter uses Java Reflection to convert POJOs into BulletRecords.

To clarify, you need to specify the POJO class you want to convert, and on construction, the converter will use Reflection to map out the POJO.

Without a schema, the converter will look through all fields but not methods and take only the fields that have valid types.

If using a schema, the converter will only look for the fields referenced. It will also look for getter methods. And it is recommended to specify getters as references where possible.

```yaml
bullet.dsl.converter.pojo.class.name: "com.your.package.YourPOJO"
```

It is also possible (and recommended) to specify getter methods as references. 

### MapBulletRecordConverter

MapBulletRecordConverter is for converting Java maps into BulletRecords.

It doesn't do anything special.

Without a schema, it will simply insert every key-value pair into a BulletRecord without type-checking.

With the schema, you can do a bit more. 

### AvroBulletRecordConverter

AvroBulletRecordConverter is for converting Avro records into BulletRecords. 

the converter expects GenericRecords.

Without a schema, it just inserts every field into a BulletRecord without typechecking.

With a schema, if you specify a RECORD type, the converter will accept avro records in addition to java maps. 

### Schema

The schema consists of a list of fields that each contain a name, reference, type, and subtype. 

The name of the field in the schema will be the name of the field in the BulletRecord.
The reference of the field in the schema is the field/value to be extracted from an object when it is converted to a BulletRecord.
If the reference is null, it is assumed that the name and the reference are the same.
The type and subtype must be specified and will be used for type-checking. They must also be a valid pair. 

Types:
1. BOOLEAN
2. INTEGER
3. LONG
4. FLOAT
5. DOUBLE
6. STRING
7. LIST
8. LISTOFMAP
9. MAP
10. MAPOFMAP
11. RECORD

Subtypes:
1. BOOLEAN
2. INTEGER
3. LONG
4. FLOAT
5. DOUBLE
6. STRING

If type is LIST, LISTOFMAP, MAP, or MAPOFMAP, then a subtype is required (otherwise, subtype must be null). 

For RECORD type, you should typically reference a map. For each key-value pair in the map, a field will be inserted into the BulletRecord. Hence, the name in a RECORD field is left empty. 

Example schema and fields:

```json
{
  "fields": [
    {
      "name": "myBool",
      "type": "BOOLEAN"
    },
    {
      "name": "myBoolMap",
      "type": "MAP",
      "subtype": "BOOLEAN"
    },
    {
      "name": "myLongMapMap",
      "type": "MAPOFMAP",
      "subtype": "LONG"
    },
    {
      "name": "myIntFromSomeMap",
      "reference": "someMap.myInt",
      "type": "INTEGER"
    },
    {
      "name": "myIntFromSomeIntList",
      "reference": "someIntList.0",
      "type": "INTEGER"
    },
    {
      "name": "myIntFromSomeNestedMapsAndLists",
      "reference": "someMap.nestedMap.nestedList.0",
      "type": "INTEGER"
    },
    {
      "reference" : "someMap",
      "type": "RECORD"
    }
  ]
}
```

## BulletDeserializer

BulletDeserializer is an abstract Java class that can be implemented to deserialize/transform output from BulletConnector to input for BulletRecordConverter.

BulletDeserializer is an optional component of Bullet DSL depending on the output of your data sources. 

If, for example, your KafkaConnector outputs Java-serialized maps (byte arrays), and you're using a MapBulletRecordConverter, you would use the JavaDeserializer, which would
deserialize the byte array into a java map for the converter. 

Currently, we support two BulletDeserializer implementations:

1. [JavaDeserializer](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/deserializer/JavaDeserializer.java)
2. [AvroDeserializer](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/deserializer/AvroDeserializer.java)

```yaml
# The classpath to the BulletRecordConverter to use
bullet.dsl.converter.class.name: "com.yahoo.bullet.dsl.converter.AvroBulletRecordConverter"
```

### JavaDeserializer

This uses Java Serialization to deserialize (java-serialized) byte arrays into objects. 

### AvroDeserializer

This uses Avro to deserialize (avro-serialized) byte arrays into avro GenericRecords.

It must be given the Avro schema for the avro record to deserialize.

This can be given either by providing the Avro schema file or the Avro class itself (the class must be in classpath)

```yaml
# The path to the Avro schema file to use prefixed by "file://"
bullet.dsl.deserializer.avro.schema.file: "file://example.avsc"

# The class name of the Avro record class to deserialize
bullet.dsl.deserializer.avro.class.name: "com.your.package.YourAvro"
```
