# Kafka PubSub

The Kafka implementation of the Bullet PubSub can be used on any Backend and Web Service. It uses [Apache Kafka](https://kafka.apache.org) as the backing PubSub queue and works on all Backends.

## How does it work?

The implementation by default asks you to create two topics in a Kafka cluster - one for queries and another for results. The Web Service publishes queries to the queries topic and reads results from the results topic. Similarly, the Backend reads queries from the queries topic and writes results to the results topic. All messages are sent as [PubSubMessages](architecture.md#messages).

You do not need to have two topics. You can have one but you should use multiple partitions and configure your Web Service and Backend to produce to and consume from the right partitions. See the [setup](#configuration) section for more details.

!!! note "Kafka Client API"

    The Bullet Kafka implementation uses the Kafka 0.10.2 client APIs. Generally, your forward or backward compatibilities should work as expected.

## Setup

Before setting up, you will need a Kafka cluster setup with your topic(s) created. This cluster need only be a couple of machines if it's devoted for Bullet. However, this depends on your query and result volumes. Generally, these are at most a few hundred or thousands of messages per second and a small Kafka cluster will suffice.

To setup Kafka, follow the [instructions here](https://kafka.apache.org/quickstart).

### Plug into the Backend

Depending on how your Backend is built, either add Bullet Kafka to your classpath or include it in your build tool. Head over to our [releases page](../releases.md#bullet-kafka) for getting the artifacts. If you're adding Bullet Kafka to the classpath instead of building a fat jar, you will need to get the jar with the classifier: ```fat``` since you will need Bullet Kafka and all its dependencies.

Configure the backend to use the Kafka PubSub:

```yaml
bullet.pubsub.context.name: "QUERY_PROCESSING"
bullet.pubsub.class.name: "com.yahoo.bullet.kafka.KafkaPubSub"
bullet.pubsub.kafka.bootstrap.servers: "server1:port1,server2:port2,..."
bullet.pubsub.kafka.request.topic.name: "your-query-topic"
bullet.pubsub.kafka.response.topic.name: "your-result-topic"
```

You will then need to configure the Publishers and Subscribers. For details on what to configure and what the defaults are, see the [configuration file](https://github.com/bullet-db/bullet-kafka/blob/master/src/main/resources/bullet_kafka_defaults.yaml).

### Plug into the Web Service

You will need the Head over to our [releases page](../releases.md#bullet-kafka) and get the JAR artifact with the ```fat``` classifier. For example, you can download the artifact for the 0.2.0 release [directly from JCenter](http://jcenter.bintray.com/com/yahoo/bullet/bullet-kafka/0.2.0/)).

You should then plug in this JAR to your Web Service following the instructions [here](../ws/setup.md#launch).

For configuration, you should [follow the steps here](../ws/setup.md#pubsub-configuration) to create and provide a YAML file to the Web Service. Remember to change the context to ```QUERY_SUBMISSION```.

```yaml
bullet.pubsub.context.name: "QUERY_SUBMISSION"
bullet.pubsub.class.name: "com.yahoo.bullet.kafka.KafkaPubSub"
bullet.pubsub.kafka.bootstrap.servers: "server1:port1,server2:port2,..."
bullet.pubsub.kafka.request.topic.name: "your-query-topic"
bullet.pubsub.kafka.response.topic.name: "your-result-topic"
```

As with the Backend, you will then need to configure the Publishers and Subscribers. See the [configuration file](https://github.com/bullet-db/bullet-kafka/blob/master/src/main/resources/bullet_kafka_defaults.yaml). Remember that your Subscribers in the Backend are reading what the Producers in your Web Service are producing and vice-versa, so make sure to match up the topics and settings accordingly if you have any custom changes.

## Passthrough Configuration

You can pass additional Kafka Producer or Consumer properties to the PubSub Publishers and Subscribers by prefixing them with either ```bullet.pubsub.kafka.producer.``` for Producers or ```bullet.pubsub.kafka.consumer.``` for Consumers. The PubSub configuration uses and provides a few defaults for settings it thinks is important to manage. You can tweak them and add others. For a list of properties that you can configure, see the [Producer](https://kafka.apache.org/0102/documentation.html#producerconfigs) or [Consumer](https://kafka.apache.org/0102/documentation.html#newconsumerconfigs) configs in Kafka.

!!! note "Types for the properties"

    All Kafka properties are better off specified as Strings since Kafka type casts them accordingly. If you provide types, you might run into issues where YAML types do not match what the Kafka client is expecting.

## Partitions

You may choose to partition your topics for a couple of reasons:

1. You may have one topic for both queries and responses and use partitions as a way to separate them.
2. You may use two topics and partition one or both for scalability when reading and writing
3. You may use two topics and partition one or both for sharding across multiple Web Service instances (and multiple instances in your Backend)

You can accomplish all this with partition maps. You can configure what partitions your Publishers (Web Service or Backend) will write to using ```bullet.pubsub.kafka.request.partitions``` and what partitions your Subscribers will read from using ```bullet.pubsub.kafka.response.partitions```. Providing these to an instance of the Web Service or the Backend in the YAML file ensures that the Publishers in that instance only write to these request partitions and Subscribers only read from the response partitions. The Publishers will randomly adds one of the response partitions in the messages sent to ensure that the responses only arrive to one of those partitions this instance's Subscribers are waiting on. For more details, see the [configuration file](https://github.com/bullet-db/bullet-kafka/blob/master/src/main/resources/bullet_kafka_defaults.yaml).

## Security

If you're using secure Kafka, you will need to do the necessary metadata setup to make sure your principals have access to your topic(s) for reading and writing. If you're using SSL for securing your Kafka cluster, you will need to add the necessary SSL certificates to the keystore for your JVM before launching the Web Service or the Backend.

### Storm

We have tested Kafka with [Bullet Storm](../releases.md#bullet-storm) using ```Kerberos``` from the Storm cluster and SSL from the Web Service. For Kerberos, you may need to add a ```JAAS``` [config file](https://docs.oracle.com/javase/7/docs/technotes/guides/security/jgss/tutorials/LoginConfigFile.html) to the [Storm BlobStore](http://storm.apache.org/releases/1.1.0/distcache-blobstore.html) and add it to your worker JVMs. To do this, you will need a JAAS configuration entry. For example, if your Kerberos KDC is shared with your Storm cluster's KDC, you may be adding a jaas_file.conf with

```
KafkaClient {
   org.apache.storm.security.auth.kerberos.AutoTGTKrb5LoginModule required
   serviceName="kafka";
};
```

Put this file into Storm's BlobStore using:

```
storm blobstore create --file jaas_file.conf --acl o::rwa,u:$USER:rwa --repl-fctr 3 jaas_file.conf
```

Then while launching your topology, you should provide as arguments to the ```storm jar``` command, the following arguments:
```
-c topology.blobstore.map='{"jaas_file.conf": {} }' \
-c topology.worker.childopts="-Djava.security.auth.login.config=./jaas_file.conf" \
```

This will add this to all your worker JVMs. You can refresh Kerberos credentials periodically and push credentials to Storm as [mentioned here](storm-drpc.md#security).
