# Bullet DSL

Bullet DSL is a configuration-based DSL that allows users to plug their data into the Bullet Backend. Instead of having users write their own code to set up the Backend on their data, users can now accomplish the same thing by simply providing the appropriate configuration to Bullet. 

To support this, Bullet DSL provides two major components. The first is for reading data from a pluggable data source, and the second is for converting data into [BulletRecords](ingestion.md). 
By enabling Bullet DSL in the Backend and configuring Bullet DSL accordingly, the backend will use the two components to read from the configured data source and convert the data into BulletRecords.

There are three main things to configure: the **BulletConnector** (Bullet DSL's reading component), the **BulletRecordConverter** (Bullet DSL's converting component), and the **Backend**.
(Additionally, there is the BulletDeserializer which is an optional component for deserializing data.)  

!!!note

    For the Backend, please refer to the DSL-specific Bullet Storm setup [here](storm-setup.md#using-bullet-dsl). (Currently, only Bullet Storm supports Bullet DSL.)

## BulletConnector

BulletConnector is an abstract Java class that can be implemented to read data from different pluggable data sources. 

Currently, we support two BulletConnector implementations:

1. [KafkaConnector](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/connector/KafkaConnector.java)
2. [PulsarConnector](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/connector/PulsarConnector.java)

These two connectors support [Apache Kafka](https://kafka.apache.org/) and [Apache Pulsar](https://pulsar.apache.org/).

For Bullet DSL, you will need to specify the BulletConnector to use. For example, if you wanted to use KafkaConnector, you would add the following to your configuration file:

```yaml
# The classpath to the BulletConnector to use (need this for Bullet DSL!)
bullet.dsl.connector.class.name: "com.yahoo.bullet.dsl.connector.KafkaConnector"

# The read timeout duration in ms (defaults to 0)
bullet.dsl.connector.read.timeout.ms: 0

# Whether or not to asynchronously commit messages (defaults to true)
bullet.dsl.connector.async.commit.enable: true
```

All BulletConnector configuration can be found in the [default configuration file](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/resources/bullet_dsl_defaults.yaml) along with specific configuration for both implementations.

!!!note

    If you have an unsupported data source and you want to use Bullet DSL, you will have to implement your own BulletConnector. If you do, however, you can help contribute it! Check out the BulletConnector interface [here](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/connector/BulletConnector.java)


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

The PulsarConnector configuration requires a few settings that are necessary to read from Pulsar; it also provides additional options to enable authentication and/or TLS.

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

Most important to note is that the connector requires a Pulsar schema whose type can be either BYTES, STRING, JSON, AVRO, PROTOBUF, or CUSTOM. 
If the schema is any type except CUSTOM, the connector will load the schema natively supported by Pulsar. For JSON, AVRO, and PROTOBUF, the POJO class to wrap must be specified though. 
For a CUSTOM schema, the schema class must be specified instead. 

You can also pass additional Pulsar Client and Consumer properties to the PulsarConnector by prefixing them with ```bullet.dsl.connector.pulsar.client``` and ```bullet.dsl.connector.pulsar.consumer``` For the lists of properties, see Pulsar [ClientConfigurationData](https://github.com/apache/pulsar/blob/master/pulsar-client/src/main/java/org/apache/pulsar/client/impl/conf/ClientConfigurationData.java) and [ConsumerConfigurationData](https://github.com/apache/pulsar/blob/master/pulsar-client/src/main/java/org/apache/pulsar/client/impl/conf/ConsumerConfigurationData.java).

## BulletRecordConverter

BulletRecordConverter is an abstract Java class that can be implemented to convert different types of data into BulletRecords.

Currently, we support three BulletRecordConverter implementations:

1. [POJOBulletRecordConverter](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/converter/POJOBulletRecordConverter.java) (POJOs)
2. [MapBulletRecordConverter](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/converter/MapBulletRecordConverter.java) (Java Maps)
3. [AvroBulletRecordConverter](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/converter/AvroBulletRecordConverter.java) (Apache Avro Records)

These converters support converting [POJOs](https://en.wikipedia.org/wiki/Plain_old_Java_object), [Java Maps](https://docs.oracle.com/javase/8/docs/api/java/util/Map.html), and [Apache Avro](https://avro.apache.org/) records to BulletRecords.

For Bullet DSL, you will need to specify the BulletRecordConverter to use. For example, to use AvroBulletRecordConverter, you would add the following to your configuration file:

```yaml
# The classpath to the BulletRecordConverter to use
bullet.dsl.converter.class.name: "com.yahoo.bullet.dsl.converter.AvroBulletRecordConverter"

# The path to the schema file to use
bullet.dsl.converter.schema.file: "your-schema-file.json"
```

Note, while a schema is not required, there are some [benefits](#schema) to using one. 

!!!note

    Unfortunately, we don't have other converters, but these should cover most use cases. If you do need a specific converter though, you can write your own. You can also help contribute. Check out the BulletRecordConverter interface [here](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/converter/BulletRecordConverter.java).

### POJOBulletRecordConverter

POJOBulletRecordConverter uses Java Reflection to convert POJOs into BulletRecords. In the configuration, you need to specify the POJO class you want to convert, and when the converter is created, it will map out the POJO with Reflection. 
Without a schema, the converter will look through all fields and accept only the fields that have valid types.
With a schema, the converter will only look for the fields referenced, but it will also accept getter methods. (It is recommended to specify getters as references where possible.)

```yaml
bullet.dsl.converter.pojo.class.name: "com.your.package.YourPOJO"
```

### MapBulletRecordConverter

MapBulletRecordConverter is used to convert Java maps into BulletRecords. Without a schema, it simply inserts every map entry into a BulletRecord without any type-checking.  

### AvroBulletRecordConverter

AvroBulletRecordConverter is used to convert Avro records into BulletRecords. Without a schema, it inserts every field into a BulletRecord without any type-checking. With a schema, you can specify a RECORD field, and the converter will accept Avro records in addition to maps. 

### Schema

The schema consists of a list of fields each described by a name, reference, type, and subtype. 

1. name - the name of the field in the BulletRecord
2. reference - the field to extract from the to-be-converted object
3. type - Blah
4. subtype - BLAHHH


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

If the field type is LIST, LISTOFMAP, MAP, or MAPOFMAP, then a subtype is required; otherwise, subtype must be null. 

For RECORD type, you should normally reference a map. For each key-value pair in the map, a field will be inserted into the BulletRecord. Hence, the name in a RECORD field is left empty. 

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

BulletDeserializer is an abstract Java class that can be implemented to deserialize/transform output from BulletConnector to input for BulletRecordConverter. It is an optional component and whether its necessary or not depends on the output of your data sources. 

If, for example, your KafkaConnector outputs byte arrays that are actually Java-serialized maps, and you're using a MapBulletRecordConverter, you would use the JavaDeserializer, which would
deserialize byte arrays into Java maps for the converter. 

Currently, we support two BulletDeserializer implementations:

1. [JavaDeserializer](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/deserializer/JavaDeserializer.java)
2. [AvroDeserializer](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/deserializer/AvroDeserializer.java)

These two deserializers support Java and [Avro](https://avro.apache.org/) serialization. 

For Bullet DSL, if you wanted to use AvroDeserializer, you would add the following to your configuration file:

```yaml
# The classpath to the BulletDeserializer to use
bullet.dsl.deserializer.class.name: "com.yahoo.bullet.dsl.deserializer.AvroDeserializer"
```

### JavaDeserializer

JavaDeserializer uses Java Serialization to deserialize (Java-serialized) byte arrays into objects. 

### AvroDeserializer

AvroDeserializer uses Avro to deserialize (Avro-serialized) byte arrays into Avro GenericRecords.

The deserializer must be given the Avro schema for the Avro records you want to deserialize. In the configuration, you can either provide the Avro schema file or the Avro class itself (the class must be in the classpath).

```yaml
# The path to the Avro schema file to use prefixed by "file://"
bullet.dsl.deserializer.avro.schema.file: "file://example.avsc"

# The class name of the Avro record class to deserialize
bullet.dsl.deserializer.avro.class.name: "com.your.package.YourAvro"
```
