# Bullet DSL

Bullet DSL is a configuration-based DSL that allows users to plug their data into the Bullet Backend. Instead of having users write their own code to set up the Backend on their data, users can now accomplish the same thing by simply providing the appropriate configuration to Bullet.

To support this, Bullet DSL provides two major components. The first is for reading data from a pluggable data source (the *connectors* for talking to various data sources), and the second is for converting data (the *converters* for understanding your data formats) into [BulletRecords](ingestion.md).
By enabling Bullet DSL in the Backend and configuring Bullet DSL, your backend will use the two components to read from the configured data source and convert the data into BulletRecords, without you having to write any code.

There is also an optional minor component that acts as the glue between the connectors and the converters. These are the *deserializers*. They exist if the data coming out of connector is of a format that cannot be understood by a converter. Typically, this happens for serialized data that needs to be deserialized first before a converter can understand it.

The four interfaces that the DSL uses are:

1. The **BulletConnector** : Bullet DSL's reading component
2. The **BulletDeserializer** : Bullet DSL's optional deserializing component
3. The **BulletRecordConverter** : Bullet DSL's converting component
4. The **Bullet Backend** : The implementation of Bullet on a Stream Processor

## BulletConnector

BulletConnector is an abstract Java class that can be implemented to read data from different pluggable data sources. As with all our components, we provide and maintain implementations while providing an interface to add new ones. Currently, we support two BulletConnector implementations:

1. [KafkaConnector](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/connector/KafkaConnector.java) for connecting to [Apache Kafka](https://kafka.apache.org/)
2. [PulsarConnector](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/connector/PulsarConnector.java) for connecting to [Apache Pulsar](https://pulsar.apache.org/)

When using Bullet DSL, you will need to specify the particular BulletConnector to use. For example, if you wanted to use the KafkaConnector, you would add the following to your configuration file:

```yaml
# The classpath to the BulletConnector to use (need this for Bullet DSL!)
bullet.dsl.connector.class.name: "com.yahoo.bullet.dsl.connector.KafkaConnector"

# The read timeout duration in ms (defaults to 0)
bullet.dsl.connector.read.timeout.ms: 0

# Whether or not to asynchronously commit messages (defaults to true)
bullet.dsl.connector.async.commit.enable: true
```

All BulletConnector configuration can be found in the [default configuration file](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/resources/bullet_dsl_defaults.yaml) along with specific default configuration for both implementations.

!!!note

    If you have an unsupported data source and you want to use Bullet DSL, you will have to implement your own BulletConnector. If you do, please do consider contributing it back! Check out the
    BulletConnector interface [here](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/connector/BulletConnector.java).


### KafkaConnector

The KafkaConnector configuration requires a few settings that are necessary to read from Kafka, including the bootstrap servers, group id, and key/value deserializers, and the topics to subscribe to.

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

The PulsarConnector configuration requires a few settings that are necessary to read from Pulsar. It also provides additional options to enable authentication and/or TLS.

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

Most important to note is that the connector requires a [Pulsar schema](https://pulsar.apache.org/docs/en/concepts-schema-registry/) whose type can be either BYTES, STRING, JSON, AVRO, PROTOBUF, or CUSTOM (defaults to BYTES). If the schema is any type except CUSTOM, the connector will load the schema natively supported by Pulsar. For JSON, AVRO, and PROTOBUF, the POJO class to wrap must be specified. For a CUSTOM schema, the schema class must be specified instead.

You can also pass additional Pulsar Client and Consumer properties to the PulsarConnector by prefixing them with ```bullet.dsl.connector.pulsar.client``` and ```bullet.dsl.connector.pulsar.consumer``` For both lists of properties, see Pulsar [ClientConfigurationData](https://github.com/apache/pulsar/blob/master/pulsar-client/src/main/java/org/apache/pulsar/client/impl/conf/ClientConfigurationData.java) and [ConsumerConfigurationData](https://github.com/apache/pulsar/blob/master/pulsar-client/src/main/java/org/apache/pulsar/client/impl/conf/ConsumerConfigurationData.java).

## BulletRecordConverter

BulletRecordConverter is an abstract Java class that can be implemented to convert different types of data formats into BulletRecords.

Currently, we support three BulletRecordConverter implementations:

1. [POJOBulletRecordConverter](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/converter/POJOBulletRecordConverter.java) to convert [POJOs](https://en.wikipedia.org/wiki/Plain_old_Java_object)
2. [MapBulletRecordConverter](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/converter/MapBulletRecordConverter.java) for [Java Maps](https://docs.oracle.com/javase/8/docs/api/java/util/Map.html) of Objects
3. [AvroBulletRecordConverter](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/converter/AvroBulletRecordConverter.java) for [Apache Avro](https://avro.apache.org/)

When using Bullet DSL, you will need to specify the appropriate BulletRecordConverter to use. The converters also support taking in an optional schema (see the [Schema section][#schema] for more details and the benefits to using one). For example, to use AvroBulletRecordConverter, you would add the following to your configuration file:

```yaml
# The classpath to the BulletRecordConverter to use
bullet.dsl.converter.class.name: "com.yahoo.bullet.dsl.converter.AvroBulletRecordConverter"

# The path to the schema file to use
bullet.dsl.converter.schema.file: "your-schema-file.json"
```

!!!note "Supported Converters"

    At this moment, these are the converters that we maintain. If you do need a specific converter though that is not yet available, you can write your own (and hopefully contribute it back!). Check out the BulletRecordConverter
    interface [here](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/converter/BulletRecordConverter.java).

### POJOBulletRecordConverter

The POJOBulletRecordConverter uses Java Reflection to convert POJOs into BulletRecords. In the configuration, you need to specify the POJO class you want to convert, and when the converter is created, it will inspect the POJO with Reflection. Without a [schema](#schema), the converter will look through all fields and accept only the fields that have valid types. With a schema, the converter will only look for the fields referenced, but it will also accept getter methods. It is recommended to specify getters as references where possible.

```yaml
bullet.dsl.converter.pojo.class.name: "com.your.package.YourPOJO"
```

### MapBulletRecordConverter

The MapBulletRecordConverter is used to convert Java Maps of Objects into BulletRecords. Without a schema, it simply inserts every entry in the Map into a BulletRecord without any type-checking. If the Map contains objects that are not types supported by the BulletRecord, you might have issues when serializing the record.

### JSONBulletRecordConverter

The JSONBulletRecordConverter is used to convert String JSON representations of records into BulletRecords. Without a schema, it simply inserts every entry in the JSON object into a BulletRecord without any type-checking and it only uses the Double type for all numeric values (since it is unable to guess whether records might need a wider type). You should use a schema and mention the appropriate types if you want more specific numeric types for the fields in your record. If the JSON contains objects that are not types supported by the BulletRecord, you might have issues when serializing the record.

### AvroBulletRecordConverter

The AvroBulletRecordConverter is used to convert Avro records into BulletRecords. Without a schema, it inserts every field into a BulletRecord without any type-checking. With a schema, you get type-checking, and you can also specify a RECORD field, and the converter will accept Avro Records in addition to Maps, flattening them into the BulletRecord. This converter also handles container types (such as Maps and Lists) that contain heterogenous nested types as well having more nesting levels than the types we support. It maps then to the appropriate Bullet `UNKNOWN_MAP`, `UNKNOWN_MAP_MAP` etc types so that queries can still be written that pull out these fields and if *they* are types that Bullet understands, the query can still execute.

### Schema

The schema consists of a list of fields each described by a name, reference, type, and subtype.

1. `name` :  The name of the field in the BulletRecord
2. `reference` : The field to extract from the to-be-converted object
3. `type` : The type of the field


When using the schema:

1. The `name` of the field in the schema will be the name of the field in the BulletRecord.
2. The `reference` of the field in the schema is the field/value to be extracted from an object when it is converted to a BulletRecord.
3. If the `reference` is null, it is assumed that the `name` and the `reference` are the same.
4. The `type` must be specified and can be used for type-checking. If you provide a schema and set the `bullet.dsl.converter.schema.type.check.enable` setting, then the converter will validate that the types in the source data matches the given type here. Otherwise, the type provided will be assumed. This is useful when initially using the DSL and you are not sure of the types.

#### Types

1. BOOLEAN
2. INTEGER
3. LONG
4. FLOAT
5. DOUBLE
6. STRING
7. BOOLEAN_MAP
8. INTEGER_MAP
9. LONG_MAP
10. FLOAT_MAP
11. DOUBLE_MAP
12. STRING_MAP
13. BOOLEAN_MAP_MAP
14. INTEGER_MAP_MAP
15. LONG_MAP_MAP
16. FLOAT_MAP_MAP
17. DOUBLE_MAP_MAP
18. STRING_MAP_MAP
19. BOOLEAN_LIST
20. INTEGER_LIST
21. LONG_LIST
22. FLOAT_LIST
23. DOUBLE_LIST
24. STRING_LIST
25. BOOLEAN_MAP_LIST
26. INTEGER_MAP_LIST
27. LONG_MAP_LIST
28. FLOAT_MAP_LIST
29. DOUBLE_MAP_LIST
30. STRING_MAP_LIST

!!!note "Special Type for a RECORD"

    There is a special case where if you omit the `type` and the `name` for an entry in the schema, the reference is assumed to be a map containing arbitrary fields with types in the list above. You can use this if you have a map field that contains various objects with one or more types in the list above and want to flatten that map out into the target record using the respective types of each field in the map. The names of the fields in the map will be used as the top-level names in the resulting record.

#### Example Schema

```json
{
  "fields": [
    {
      "name": "myBool",
      "type": "BOOLEAN"
    },
    {
      "name": "myBoolMap",
      "type": "BOOLEAN_MAP"
    },
    {
      "name": "myLongMapMap",
      "type": "LONG_MAP_MAP"
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
      "reference" : "someMap"
    }
  ]
}
```

## BulletDeserializer

BulletDeserializer is an abstract Java class that can be implemented to deserialize/transform output from BulletConnector to input for BulletRecordConverter. It is an *optional* component and whether it's necessary or not depends on the output of your data sources. If one is not needed, the `IdentityDeserializer` can be used. For example, if your KafkaConnector outputs byte arrays that are actually Java-serialized Maps, and you're using a MapBulletRecordConverter, you would use the JavaDeserializer, which would deserialize byte arrays into Java Maps for the converter.

Currently, we support two BulletDeserializer implementations:

1. [JavaDeserializer](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/deserializer/JavaDeserializer.java)
2. [AvroDeserializer](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/deserializer/AvroDeserializer.java)

For Bullet DSL, if you wanted to use AvroDeserializer, you would add the following to your configuration file:

```yaml
# The classpath to the BulletDeserializer to use
bullet.dsl.deserializer.class.name: "com.yahoo.bullet.dsl.deserializer.AvroDeserializer"
```

### JavaDeserializer

The JavaDeserializer uses Java Serialization to deserialize (Java-serialized) byte arrays into objects.

### AvroDeserializer

The AvroDeserializer uses Avro to deserialize (Avro-serialized) byte arrays into Avro GenericRecords.

The deserializer must be given the Avro schema for the Avro records you want to deserialize. In the configuration, you can either provide the Avro schema file (note the `file://` prefix) or the Avro class itself (the class must be in the classpath).

```yaml
# The path to the Avro schema file to use prefixed by "file://"
bullet.dsl.deserializer.avro.schema.file: "file://example.avsc"

# The class name of the Avro record class to deserialize
bullet.dsl.deserializer.avro.class.name: "com.your.package.YourAvro"
```
