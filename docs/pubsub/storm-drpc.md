# Storm DRPC PubSub

Bullet on [Storm](https://storm.apache.org/) can use [Storm DRPC](http://storm.apache.org/releases/1.0.0/Distributed-RPC.html) as a PubSub layer. DRPC or Distributed Remote Procedure Call, is built into Storm and consists of a set of servers that are part of the Storm cluster.

## How does it work?

When a Storm topology that uses DRPC is launched, it registers a spout with a unique name (the procedure in the Distributed Remote Procedure Call) with the DRPC infrastructure. The DRPC Servers expose a REST endpoint where data can be POSTed to or a GET request can be made with this unique name. The DRPC infrastructure then sends the request (a query in Bullet) through the spout(s) to the topology that registered that name (Bullet). The result from topology is sent back to the client. We picked Storm to implement Bullet on first not only because it was the most popular Streaming framework at Yahoo but also since DRPC provides us a nice and simple way to handle getting queries into Bullet and sending responses back.

You can communicate with DRPC using [Apache Thrift](https://thrift.apache.org) or REST. Our implementation uses REST. The Web Service sends a JSON serialized PubSubMessage with the query in it through HTTP and asynchronously waits for the results back through DRPC.

!!! note "REST and DRPC"

    While DRPC exposes a [Thrift](http://thrift.apache.org) endpoint, the PubSub implementation uses REST. When you launch your topology with the DRPC PubSub, you can POST a JSON Bullet PubSubMessage containing a String JSON query to a DRPC server directly with the function name that you specify in the [Bullet configuration](#storm-backend). For example,
    ```bash
      curl -s -X POST -d '{"id":"", "content":"{}"}' http://<DRPC_SERVER>:<DRPC_PORT>/drpc/<DRPC_FUNCTION_FROM_YOUR_BULLET_CONF>
    ```
     to get a random record (inside a JSON representation of a PubSubMessage) from your data instantly if you left the Raw aggregation micro-batch size at the default of 1. The ```content``` above in the JSON is the actual (empty) Bullet query. This is a quick way to check if your topology is up and running!

## Setup

The DRPC PubSub is part of the [Bullet Storm](../releases.md#bullet-storm) starting with versions 0.6.2 and above.

### Plug into the Storm Backend

When you are setting up your Bullet topology with your plug-in data source (a Spout or a topology), you will naturally build a JAR with all the dependencies or a *fat* JAR. This will include all the DRPC PubSub code and dependencies. You do not need anything else. For configuration, the YAML file that you probably already provide to your topology needs to have the additional settings listed below (the function name is optional but you should change the default since the DRPC function needs to be unique per Storm cluster). Now if you launch your topology, it should be wired up to use Storm DRPC.

```yaml
bullet.pubsub.context.name: "QUERY_PROCESSING"
bullet.pubsub.class.name: "com.yahoo.bullet.storm.drpc.DRPCPubSub"
bullet.pubsub.storm.drpc.function: "custom-name"
```

### Plug into the Web Service

When you're plugging in the DRPC PubSub layer into your Web Service, you will need the Bullet Storm JAR with dependencies that you can download from [JCenter](../releases.md#bullet-storm). The classifier for this JAR is ```fat``` if you are depending on it through Maven. You can also download the JAR for the 0.6.2 version directly through [JCenter here](http://jcenter.bintray.com/com/yahoo/bullet/bullet-storm/0.6.2/).

You should then plug in this JAR to your Web Service following the instructions [here](../ws/setup.md#launch).

For configuration, you should [follow the steps here](../ws/setup.md#pubsub-configuration) and add the context and class name listed above. You will need to point to your DRPC servers and set the function to the same value you chose [above](#storm-backend). You can configure this and other settings that are explained further in the [PubSub and PubSub Storm DRPC defaults section](https://github.com/yahoo/bullet-storm/blob/master/src/main/resources/bullet_storm_defaults.yaml) in the Bullet Storm defaults file.

```yaml
bullet.pubsub.context.name: "QUERY_SUBMISSION"
bullet.pubsub.class.name: "com.yahoo.bullet.storm.drpc.DRPCPubSub"
bullet.pubsub.storm.drpc.servers:
  - server1
  - server2
  - server3
bullet.pubsub.storm.drpc.function: "custom-name"
bullet.pubsub.storm.drpc.http.protocol: "http"
bullet.pubsub.storm.drpc.http.port: "4080"
bullet.pubsub.storm.drpc.http.path: "drpc"
bullet.pubsub.storm.drpc.http.connect.retry.limit: 3
bullet.pubsub.storm.drpc.http.connect.timeout.ms: 1000
```

## Caveats with Storm DRPC

#### Scalability

DRPC servers are a shared resource per Storm cluster and it may be possible that you have to contend with other topologies in your multi-tenant cluster. While it is horizontally scalable, it does tie the scalability of the Bullet backend to it. If you only have a few DRPC servers in your Storm cluster, you may need to add more to support more simultaneous DRPC requests. We have [found that](../backend/storm-performance.md#conclusion_3) each server gives us about ~250 simultaneous queries. There is an Async implementation coming in Storm 2.0 that should increase the throughput.

#### Query Duration

The maximum time a query can run for depends on the maximum time Storm DRPC request can last in your Storm topology. Generally the default is set to 10 minutes. This means that the **longest query duration possible will be 10 minutes**. The value of this is up to your cluster maintainers.

#### Request-Response

Our PubSub uses DRPC using HTTP REST in a request-response model. This means that it will not support incremental results as it is! We could switch our usage of DRPC to send signals to the topology to fetch results and start queries. Depending on if there is demand, we may support this in our implementation in the future.

#### Reliability

Storm DRPC follows the principle of leaving retries to the DRPC user (in our case, the Bullet web service). At this moment, we have not chosen to add reliability mechanisms to the query publishing, result publishing or result subscribing sides of our DRPC PubSub implementations but the query subscribers do use the ```BufferingSubscriber``` mentioned [here](architecture.md#reliability).
