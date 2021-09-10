# PubSub Architecture

This section describes how the Publish-Subscribe or [PubSub layer](../index.md#pubsub) works in Bullet.

## Why a PubSub?

When we initially created Bullet, it was built on [Apache Storm](https://storm.apache.org) and leveraged a feature in it called Storm DRPC to deliver queries to and extract results from the Bullet Backend. Storm DRPC is supported by a set of clusters that are physically part of the Storm cluster and is a shared resource for the cluster. While many other stream processors support some form of RPC and we could support multiple versions of the Web Service for those, it quickly became clear that abstracting the transport layer from the Web Service to the Backend was needed. This was particularly highlighted when we wanted to switch Bullet queries from operating in a request-response model (one response at the end of the query) to a streaming model. Streaming responses back to the user for a query through DRPC would be cumbersome and require a lot of logic to handle. A PubSub system was a natural solution to this. Since DRPC was a shared resource per cluster, we also were [tying the Backend's scalability](../backend/storm-performance.md#test-4-improving-the-maximum-number-of-simultaneous-raw-queries) to a resource that we didn't control.

However, we didn't want to pick a particular PubSub like Kafka and restrict a user's choice. So, we added a PubSub layer that was generic and entirely pluggable into both the Backend and the Web Service. We would support a select few like [Kafka](https://github.com/bullet-db/bullet-kafka) or [Storm DRPC](https://github.com/bullet-db/bullet-storm). See [below](#implementing-your-own-pubsub) for how to create your own.

With the transport mechanism abstracted out, it opens up a lot of possibilities like implementing Bullet on other stream processors, allowing for the development of [Bullet on Spark](../backend/spark-architecture.md) along with other possible implementations in the future.

## What does it do?

A PubSub operates in two contexts:

1. Submitting queries and reading results. This is the ```QUERY_SUBMISSION``` context and the PubSub mode for the Web Service
2. Reading queries and submitting results. This is the ```QUERY_PROCESSING``` context and the PubSub mode for the Backend

A PubSub provides Publisher and Subscriber instances that, depending on the context it is in, will write and read differently. Publishers in ```QUERY_SUBMISSION``` write queries to your PubSub whereas Publishers in ```QUERY_PROCESSING``` write results. Similarly, Subscribers in ```QUERY_SUBMISSION``` read results, but Subscribers in ```QUERY_PROCESSING``` read queries. A Publisher and Subscriber in a particular context make up read and write halves of the *pipes* for stream of queries and stream of results.

### Messages

The PubSub layer does not deal with queries and results and just works on instances of messages of type ```com.yahoo.bullet.pubsub.PubSubMessage```. These [PubSubMessages](https://github.com/bullet-db/bullet-core/blob/master/src/main/java/com/yahoo/bullet/pubsub/PubSubMessage.java) are keyed (```id``` and ```sequence```), store content and metadata. This is a light wrapper around the payload and is tailored to work with multiple results per query and support communicating additional information and signals to and from the PubSub in addition to just queries and results.

### SerDe

The PubSub layer also supports a ```PubSubMessageSerDe``` interface to customize how the data is stored in the message. The SerDe is only used for publishing a message from the Web Service and for reading it in the backend. This is particularly relevant if you are storing the PubSubMessage in a [storage layer](../ws/setup.md#storage-configuration) for resiliency. Using an appropriate SerDe controls how the payload is serialized and deserialized for transportation and storage. For instance (and by default), the [ByteArrayPubSubMessageSerDe](https://github.com/bullet-db/bullet-core/blob/master/src/main/java/com/yahoo/bullet/pubsub/ByteArrayPubSubMessageSerDe.java) is used for queries. This converts the Query object payload into a byte[] when storing and transmitting it to the backend. The backend, however, does not reify the payload back into a Query object till it needs the Query. So the PubSubMessage can be serialized and deserialized multiple times as it is transferred between components without needless conversions back and forth. You can write your own if you wish to customize the behavior and control what is stored in the Storage layer if one is used. For instance, BQL provides a [LazyPubSubMessageSerDe](https://github.com/bullet-db/bullet-bql/blob/master/src/main/java/com/yahoo/bullet/bql/query/LazyPubSubMessageSerDe.java) that keeps the query as a String and makes the backend create the Query object using BQL (normally this is done in the API)!

## Choosing a PubSub implementation

If you want to use an implementation already built, we currently support:

1. [Kafka](kafka.md#setup) for any Backend
2. [Pulsar](pulsar.md#setup) for any Backend
2. [REST](rest.md#setup) for any Backend
3. [Storm DRPC](storm-drpc.md#setup) if you're using Bullet on Storm as your Backend

## Implementing your own PubSub

The core of the PubSub interfaces are defined in the [core Bullet library](https://github.com/bullet-db/bullet-core/tree/master/src/main/java/com/yahoo/bullet/pubsub) that you can [depend on](../releases.md#bullet-core).

To create a PubSub, you should extend the abstract class ```com.yahoo.bullet.pubsub.PubSub``` and implement the abstract methods for getting instances of Publishers (```com.yahoo.bullet.pubsub.Publisher```) and Subscribers (```com.yahoo.bullet.pubsub.Subscriber```). Depending on how you have configured the Web Service and the Backend, they will call the required methods to get the required number of Publishers or Subscribers to parallelize the reading or the writing. You should ensure that they are thread-safe. They will most likely be tied to your units of parallelisms for the underlying PubSub you are invoking.

If you are running sharded instances of your Web Service, you should ensure that your Publishers writing queries add Metadata to the messages to help the Publishers writing results to send the results back to the right Web Service instance that is waiting for them.

### Reliability

You can choose to make your Publishers and Subscribers as reliable as you want. Both the Web Service and the Backend will call the appropriate reliability methods (```commit``` and ```fail```), but your implementations can choose to be no-ops if you do not want to implement reliability. Alternatively, if you want to make your Subscribers reliable, you could use a simple, in-memory reliable implementation by extending ```com.yahoo.bullet.pubsub.BufferingSubscriber```. This keeps track of uncommitted messages in memory up to a configured threshold (does not read more messages if there are this many uncommitted messages left) and re-emits messages on failures using it.

### Canonical example

For an example of a PubSub implementation, see the [Bullet Kafka PubSub project](https://github.com/bullet-db/bullet-kafka). This is implemented in Java and is a simple implementation that wraps the Kafka client APIs. It supports reliability through the use of the ```BufferingSubscriber``` mentioned above. It allows you to specify one or two Kafka topics for queries and results. It can be sharded across multiple Web Service machines using Kafka topic partitions. See the [configuration](https://github.com/bullet-db/bullet-kafka/blob/master/src/main/resources/bullet_kafka_defaults.yaml) for details.
