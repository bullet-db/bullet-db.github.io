# Bullet DSL

A DSL for users to plug in their data source into the Bullet Backend and Web Service.

# What is it?

To help with data ingestion, Bullet DSL provides BulletConnector which reads data from a pluggable datasource and BulletRecordConverter which converts the data into BulletRecords. 

Currently, we have BulletConnectors implemented for [Apache Kafka](https://kafka.apache.org) and [Apache Pulsar](https://pulsar.apache.org) and BulletRecordConverters implemented for converting POJOs, Maps, and Avro records. 
It is also possible to implement your own custom BulletConnectors and BulletRecordConverters.

## Why use it?

The Bullet Storm and Spark Backends each provide a reading component that uses Bullet DSL, and Bullet DSL can be configured to use any BulletConnector and BulletRecordConverter. 

This means that users can plug in their data sources to the Backend through configuration, whereas previously, they had to write their own reading components that would read and convert their data into BulletRecords. 

## How do you use it?

WIP

First, configure BulletDSL to use the appropriate BulletConnector and BulletRecordConverter. 

Second, configure your BulletConnector for your data source.

Third, configure your BulletRecordConverter for your data. You may want to provide a schema. 

Fourth, in storm, enable the DSLSpout. Note, connectors and converters are configured on the storm launcher and not on the workers.

## Setup

While the Bullet Storm Backend does use Bullet DSL, it does include a fat jar and is therefore missing dependencies. 
If you plan on using KafkaConnector, you will have to include the [kafka-clients](https://bintray.com/bintray/jcenter/org.apache.kafka%3Akafka-clients/) jar in the classpath. 
If you plan on using PulsarConnector, you will need the [pulsar-client](https://bintray.com/bintray/jcenter/org.apache.pulsar%3Apulsar-client) jar instead. 

## BulletConnector

BulletConnector reads data from a pluggable data source. It is an abstract Java class that can be implemented to support different data sources.  

Currently, we support two implementations of BulletConnector:

1. [KafkaConnector](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/connector/KafkaConnector.java)
2. [PulsarConnector](https://github.com/bullet-db/bullet-dsl/blob/master/src/main/java/com/yahoo/bullet/dsl/connector/PulsarConnector.java)

In the configuration, you should specify the appropriate implementation for Bullet DSL to use.

```yaml
# The classpath to the BulletConnector to use
bullet.dsl.connector.class.name: "com.yahoo.bullet.dsl.connector.KafkaConnector"
# The read timeout duration in ms
bullet.dsl.connector.read.timeout.ms: 0
# Whether or not to asynchronously commit messages
bullet.dsl.connector.async.commit.enable: true
```

Each implementation also has its own specific configuration, and they can be found in the [default configuration file]().

### KafkaConnector Configuration

The KafkaConnector configuration only requires a few settings that are necessary to read from Kafka.

```yaml
# The list of Kafka topics to subscribe to (required)
bullet.dsl.connector.kafka.topics:
- ""
# Whether or not the KafkaConsumer should seek to the end of its subscribed topics at initialization
bullet.dsl.connector.kafka.start.at.end.enable: false

# Kafka properties (prefixed by "bullet.dsl.connector.kafka.") are passed to KafkaConsumer during construction with the
# prefix removed. The properties below are required.
# Properties found at: https://kafka.apache.org/20/javadoc/org/apache/kafka/clients/consumer/ConsumerConfig.html
bullet.dsl.connector.kafka.bootstrap.servers: "localhost:9092"
bullet.dsl.connector.kafka.group.id:
bullet.dsl.connector.kafka.key.deserializer: "org.apache.kafka.common.serialization.StringDeserializer"
bullet.dsl.connector.kafka.value.deserializer:
```

Note that you can pass additional Kafka properties to the KafkaConnector by prefixing them with ```bullet.dsl.connector.kafka.```.

For a list of properties that you can configure, see the [Consumer](https://kafka.apache.org/0102/documentation.html#newconsumerconfigs) configs in Kafka.


### PulsarConnector Configuration

The PulsarConnector configuration requires a few settings that are necessary to read from Pulsar and also provides the option for enabling Pulsar Client Authentication.

```yaml
# The list of Pulsar topics to subscribe to (required)
bullet.dsl.connector.pulsar.topics:
- ""
# The classpath to the Pulsar Schema to use (required)
bullet.dsl.connector.pulsar.schema.class.name:

# PulsarClient properties (prefixed by "bullet.dsl.connector.pulsar.client.") are passed to PulsarClient during construction
# with the prefix removed. Note, serviceUrl is required.
# Properties found at: https://github.com/apache/pulsar/blob/master/pulsar-client/src/main/java/org/apache/pulsar/client/impl/conf/ClientConfigurationData.java
bullet.dsl.connector.pulsar.client.serviceUrl: "pulsar://localhost:6650"

# PulsarClient authentication properties (disabled by default)
bullet.dsl.connector.pulsar.auth.enable: false
bullet.dsl.connector.pulsar.auth.plugin.class.name:
bullet.dsl.connector.pulsar.auth.plugin.params.string:

# Pulsar Consumer properties (prefixed by "bullet.dsl.connector.pulsar.consumer.") are passed to Consumer during construction
# with the prefix removed. Note, subscriptionName is required.
# Properties found at: https://github.com/apache/pulsar/blob/master/pulsar-client/src/main/java/org/apache/pulsar/client/impl/conf/ConsumerConfigurationData.java
bullet.dsl.connector.pulsar.consumer.subscriptionName: ""
# PulsarConnector overrides the default subscriptionType -- "Exclusive" -- and uses "Shared" if it's not explicitly set
bullet.dsl.connector.pulsar.consumer.subscriptionType: "Shared"
```

Note that you can pass additional Pulsar Client and Consumer properties to the PulsarConnector by prefixing them with ```bullet.dsl.connector.pulsar.```.

For a list of properties that you can configure, see the Pulsar [Client](https://github.com/apache/pulsar/blob/master/pulsar-client/src/main/java/org/apache/pulsar/client/impl/conf/ClientConfigurationData.java) and [Consumer](https://github.com/apache/pulsar/blob/master/pulsar-client/src/main/java/org/apache/pulsar/client/impl/conf/ConsumerConfigurationData.java) config classes.

## BulletRecordConverter

The BulletRecordConverter is used to read data from a pluggable data source. It is an abstract Java class that can be implemented to support different data sources. 

Currently, we support three implementations of BulletRecordConverter:

1. POJOBulletRecordConverter
2. MapBulletRecordConverter
3. AvroBulletRecordConverter

These converters support converting POJOs, Maps, and Avro records to BulletRecords.

In the configuration, you should specify the appropriate implementation for Bullet DSL to use and, optionally, a schema as well.

```yaml
# The classpath to the BulletRecordConverter to use
bullet.dsl.converter.class.name: "com.yahoo.bullet.dsl.converter.AvroBulletRecordConverter"
# The path to the schema file to use
bullet.dsl.converter.schema.file: "your-schema-file.json"
```

While a schema is not required, BulletRecordConverter is a lot less flexible without it and also will not type-check. 

### BulletRecordSchema

The BulletRecordSchema consists of a list of BulletRecordFields each containing a name, reference, type, and subtype. 
As a JSON object, the schema holds an array of field objects, each with a name, reference, type, and subtype.

The schema specifies the names of the fields projected into the BulletRecords and the values they reference from the objects to be converted. 
If a reference is null, the named of the field will be used instead.

Possible types are: BOOLEAN, INTEGER, LONG, FLOAT, DOUBLE, STRING, LIST, LISTOFMAP, MAP, MAPOFMAP, and RECORD.

Possible subtypes are: BOOLEAN, INTEGER, LONG, FLOAT, DOUBLE, AND STRING.

Note, if type is MAP, MAPOFMAP, LIST, or LISTOFMAP, then a subtype is required (otherwise subtype must be null). If type is RECORD, then name should be left empty.

The RECORD field is unnamed because only its children are inserted into the top-level of the BulletRecord. 
Typically, the RECORD field will reference a Map, but AvroBulletRecordConverter also supports referencing Avro records. 

Example schema and fields:

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
    
### Extra notes

For POJOBulletRecordConverter, additional configuration is needed to specify the targeted POJO class. 

```yaml
bullet.dsl.converter.pojo.class.name: "com.your.package.YourPOJO"
```

Also, it is recommended to reference getters instead of fields for better performance.

## Extra: Serialization/Deserialization

WIP
