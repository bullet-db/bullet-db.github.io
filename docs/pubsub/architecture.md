# PubSub Architecture

This section describes how the Publish-Subscribe or [PubSub layer](../index.md#pubsub) works in Bullet.

## Why a PubSub?

When we initially created Bullet, it was built on [Apache Storm](https://storm.apache.org) and leveraged a feature in it called [Storm DRPC](http://storm.apache.org/releases/1.0.3/Distributed-RPC.html) to deliver queries to and extract results from the Bullet Backend. Storm DRPC is supported by a set of clusters that are physically part of the Storm cluster and is a shared resource for the cluster. While many other stream processors support some form of RPC and we could support multiple versions of the Web Service for those, it quickly became clear that abstracting the transport layer from the Web Service to the Backend was needed. This was particularly highlighted when we wanted to switch Bullet queries from operating in a request-response model (one response at the end of the query) to a streaming model. Streaming responses back to the user for a query through DRPC would be cumbersome and require a lot of logic to handle. A PubSub system was a natural solution to this. Since DRPC was a shared resource per cluster, we also were [tying the Backend's scalability](../backend/storm-performance.md#test-4-improving-the-maximum-number-of-simultaneous-raw-queries) to a resource that we didn't control.

However, we didn't want to pick a particular PubSub like Kafka and restrict a user's choice. So, we added a PubSub layer that was generic and entirely pluggable into both the Backend and the Web Service. We would support a select few like [Kafka](https://github.com/yahoo/bullet-kafka) or [Storm DRPC](https://github.com/yahoo/bullet-storm). See [below](#implementing-your-own-pubsub) for how to create your own.

With the transport mechanism abstracted out, it opens up a lot of possibilities like implementing Bullet on other stream processors ([Apache Spark](https://spark.apache.org) is in the works) and adding streaming, incremental results, sharding and much more.

## What does it do?

A PubSub operates in two contexts:

1. Submitting queries and reading results. This is the ```QUERY_SUBMISSION``` context and this is PubSub mode for the Web Service
2. Reading queries and submitting results. This is the ```QUERY_PROCESSING``` context and this is PubSub mode for the Backend

A PubSub provides Publisher and Subscriber instances that, depending on which context it is in, do the right thing. Publishers in ```QUERY_SUBMISSION``` write queries to your PubSub whereas in ```QUERY_PROCESSING```, they write results. Similarly, the Subscribers in ```QUERY_SUBMISSION``` read results but read queries in ```QUERY_PROCESSING```. A Publisher and Subscriber in a particular context make up read and write halves of the *pipes* for stream of queries and stream of results.

### Messages

The PubSub layer does not deal with queries and results and just works on instances of messages of type ```com.yahoo.bullet.pubsub.PubSubMessage```. These [PubSubMessages](https://github.com/yahoo/bullet-core/blob/master/src/main/java/com/yahoo/bullet/pubsub/PubSubMessage.java) are keyed (```id``` and ```sequence```), store content and metadata. This is a light wrapper around the payload and is tailored to work with multiple results per query and support communicating additional information and signals to and from the PubSub in addition to just queries and results.

## Choosing a PubSub implementation

If you want to use an implementation already built, we currently support:

1. [Kafka](kafka-setup.md#setup) for any Backend
2. [Storm DRPC](storm-drpc-setup.md#setup) if you're using Bullet on Storm as your Backend

## Implementing your own PubSub

The core of the PubSub interfaces are defined in the [core Bullet library](https://github.com/yahoo/bullet-core/tree/master/src/main/java/com/yahoo/bullet/pubsub) that you can [depend on](../releases.md#bullet-core).

To create a PubSub, you should extend the abstract class ```com.yahoo.bullet.pubsub.PubSub``` and implement the abstract methods for getting instances of Publishers (```com.yahoo.bullet.pubsub.Publisher```) and Subscribers (```com.yahoo.bullet.pubsub.Subscriber```). Depending on how you have configured the Web Service and the Backend, they will call the required methods to get the required number of Publishers or Subscribers to parallelize the reading or the writing. You should ensure that they are thread-safe. They will most likely be tied to your units of parallelisms for the underlying PubSub you are invoking.

If you are running sharded instances of your Web Service, you should ensure that your Publishers writing queries add Metadata to the messages to help the Publishers writing results to send the results back to the right Web Service instance that is waiting for them.

### Reliability

You can choose to make your Publishers and Subscribers as reliable as you want. Both the Web Service and the Backend will call the appropriate reliability methods (```commit``` and ```fail```) but your implementations can choose to be no-ops if you do not want to be reliability. Alternatively, if you want make your Subscribers reliable, you could use an in-memory reliable implementation of one by extending ```com.yahoo.bullet.pubsub.BufferingSubscriber``` for a simple implementation. This keeps track of uncommitted messages in memory up to a configured threshold (does not read more messages if there are this many uncommitted messages left) and re-emits messages on failures using it.

### Canonical example

For an example of a PubSub implementation, see the [Bullet Kafka PubSub project](https://github.com/yahoo/bullet-kafka). This is implemented in Java and is a simple implementation that wraps the Kafka client APIs. It supports reliability through the use of the ```BufferingSubscriber``` mentioned above. It allows you to specify one or two Kafka topics for queries and results. It can be sharded across multiple Web Service machines using Kafka topic partitions. See the [configuration](https://github.com/yahoo/bullet-kafka/blob/master/src/main/resources/bullet_kafka_defaults.yaml) for details.
