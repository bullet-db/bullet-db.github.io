# Performance in Storm

Measuring performance of a Bullet instance running on a multi-tenant Storm cluster is not an easy task. There are a lot of independent variables that we could vary and have an effect including:

1. The amount of data we consume
2. The number of simultaneous queries Bullet runs
3. The kinds of simultaneous queries - ```RAW```, ```GROUP```, ```COUNT DISTINCT```, etc.
4. Varying parallelisms of the components - increase the parallelisms of Filter bolts disproportionately to others
5. The hardware configuration of machines
6. The various Storm versions
7. How free the cluster is and the kinds of topologies running on the cluster - CPU heavy, Disk/memory heavy, network heavy etc
8. The source of the data and tuning consumption from it

...and many more.

In this section, we will focus on analyzing the effects of primarily 1 and 2, while keeping the others fixed or as fixed as possible while running on a multi-tenant Storm cluster.

!!! note "Work in Progress"

    This page is a work in progress. It will continue to be updated and iterated upon. The idea to give users some insight into how Bullet runs in general and how to tweak Bullet components. This is *not* a benchmark and your mileage may vary.


## Prerequisites

The rest of this document assumes that you are familiar with [Storm](http://storm.apache.org), [Kafka](http://kafka.apache.org) and the [Bullet on Storm architecture](storm-architecture.md).

##  How was this tested?

All tests run here were using [Bullet-Storm 0.3.1](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.3.1). The intent is to test just the Storm piece without going through the Web Service or the UI. The DRPC REST endpoint provided by Storm lets us do just that.

Using the pluggable metrics interface in Bullet on Storm, various worker level metrics such as CPU time, Heap usage, GC times and types, were captured and sent to a Yahoo in-house monitoring service for time-slicing and graphing. The graphs shown in the tests below use this service. See [0.3.0](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.3.0) for details on how to plug in your own metrics collection.

### Cluster

* Running a custom build of Storm - Storm 0.10.2 with Storm 1.0+ features backported. For all intents and purposes, it's Storm 1.0.3
* Machines were of different configurations but all Storm workers for Bullet were running on:
    - 2 x Intel E5-2680v3 (12 core, 24 threads) - One reserved core gives each machine 47 cores from the Storm scheduler point of view
    - 256 GB RAM
    - 4 TB SATA Disk
    - 10 G Network Interface
* Multi-tenant cluster with other topologies running. Average utilizations ranging from *70% - 90%*

### Data

* Reading from a Kafka 0.9.0.1 topic partitioned into 64 partitions
* The Kafka cluster was located within the same datacenter as the Storm cluster - close network proximity gives us some measure of confidence that large data transmission delays aren't a factor.
* The metrics for the Kafka topic for the month before testing:
    - The data records or messages per second (mps) for the topic was 43,000 mps to 207,000 mps with an average of 172,000 mps
    - The compressed data output of the topic was 22 MB/s to 128 MB/s with an average of 78 MB/s. Compressed data is roughly 80% the size of the uncompressed data

Since there is a lot of variance, for each of the tests below, the data volume at that time will be provided in this format: ```Data: XX MPS and XX MB/s``` , where each of the numbers are the average for each metric over the last hour of when the test was done.

### Configuration

Here is the default configuration we used to launch the basic instance of Bullet on Storm:

```YAML
bullet.topology.metrics.enable: true
bullet.topology.metrics.built.in.enable: true
bullet.topology.metrics.built.in.emit.interval.mapping:
   bullet_active_rules: 5
   default: 60
bullet.topology.metrics.classes:
  - "package.containing.our.custom.class.pushing.metrics"
bullet.topology.drpc.spout.parallelism: 2
bullet.topology.drpc.spout.cpu.load: 20.0
bullet.topology.drpc.spout.memory.on.heap.load: 128.0
bullet.topology.drpc.spout.memory.off.heap.load: 192.0
bullet.topology.prepare.bolt.parallelism: 1
bullet.topology.prepare.bolt.cpu.load: 20.0
bullet.topology.prepare.bolt.memory.on.heap.load: 128.0
bullet.topology.prepare.bolt.memory.off.heap.load: 192.0
bullet.topology.filter.bolt.parallelism: 128
bullet.topology.filter.bolt.cpu.load: 100.0
bullet.topology.filter.bolt.memory.on.heap.load: 1024.0
bullet.topology.filter.bolt.memory.off.heap.load: 192.0
bullet.topology.return.bolt.parallelism: 1
bullet.topology.return.bolt.cpu.load: 20.0
bullet.topology.return.bolt.memory.on.heap.load: 128.0
bullet.topology.return.bolt.memory.off.heap.load: 192.0
bullet.topology.join.bolt.parallelism: 2
bullet.topology.join.bolt.cpu.load: 50.0
bullet.topology.join.bolt.memory.on.heap.load: 512.0
bullet.topology.join.bolt.memory.off.heap.load: 192.0
bullet.topology.join.bolt.error.tick.timeout: 3
bullet.topology.join.bolt.rule.tick.timeout: 3
bullet.topology.tick.interval.secs: 1
bullet.rule.default.duration: 30000
bullet.rule.max.duration: 540000
bullet.rule.aggregation.max.size: 512
bullet.rule.aggregation.raw.max.size: 500
```
Any setting not listed here default to the defaults in [bullet_defaults.yaml](https://github.com/yahoo/bullet-storm/blob/bullet-storm-0.3.0/src/main/resources/bullet_defaults.yaml). In particular, **metadata collection** and **timestamp injection** is enabled. ```RAW``` type queries also micro-batch by size 1 (in other words, do not micro-batch).

The topology was also launched (command-line args to Storm) with the following Storm settings:

```bash
storm jar
    ...
    --bullet-spout-parallelism 64
    --bullet-spout-cpu-load 100.0 \
    --bullet-spout-on-heap-memory-load 1536.0 \
    --bullet-spout-off-heap-memory-load 192.0 \
    -c topology.acker.executors=256 \
    -c topology.max.spout.pending=20000 \
    -c topology.backpressure.enable=false \
    -c topology.worker.max.heap.size.mb=4096.0 \
    -c topology.worker.gc.childopts="-XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:NewSize=128m -XX:CMSInitiatingOccupancyFraction=70 -XX:-CMSConcurrentMTEnabled -XX:NewRatio=1" \
    ...
```

1. The spout parallelism is 64 because it is going to read from a Kafka topic with 64 partitions (any more is meaningless since it cannot be split further). It reads and converts the data into Bullet Records.
2. We've fanned out from the spouts to the Filter bolts by a ratio of 2. We will see if we actually need this ratio below.
3. We use ```topology.max.spout.pending=20000``` to limit the number of in-flight tuples there can be from a DataSource Spout instance and throttle it if too many queries are slowing down processing downstream. This is set pretty high to account for catch-up and skew in our Kafka partitions
4. We have set the max heap size for a worker to ```4 GiB``` since we do not want too large of a worker. If a component dies or causes a worker to be killed by RAS, it will not affect too many other workers. It also makes heap dumps etc manageable.
5. We set ```topology.worker.gc.childopts``` to use ```ParNewGC``` and ```CMS```. These are our cluster defaults but we are listing them here since this may not be true for all Storm clusters. We have also added the ```-XX:NewRatio=1``` to the defaults since most of our objects are short-lived and having a larger Young Generation reduces our Young Generation GC (ParNew) frequency.

### Resource utilization

With these configurations, the total resource usage is:

<div class="mostly-numeric-table"></div>

|     Component       | Parallelism |CPU (cores) | Total Memory (MB) |
| :------------------ | ----------: | ---------: | ----------------: |
| DataSource Spout    |64           |64          | 110592            |
| Filter Bolt         |128          |128         | 155648            |
| Join Bolt           |2            |1           | 1408              |
| DRPC Spout          |2            |0.4         | 640               |
| PrepareRequest Bolt |1            |0.2         | 320               |
| ReturnResults Bolt  |1            |0.2         | 320               |
| IMetricsConsumer    |1            |0.1         | 256               |
| Ackers              |256          |25.6        | 32768             |
| **Total**           |**455**      |**219.5**   | **334720**        |

With these ~47 core machines, we would need ```5``` of these machines to run this instance of Bullet reading this data source and supporting a certain number of queries. What this certain number is, we will determine below.

!!! note "How will this work for different data and query loads?"

    It won't. We will list changes to settings as we change data loads and queries. The settings listed above are the baseline.


### Tools

  * [jq](https://stedolan.github.io/jq/) - a nice tool to parse Bullet JSON responses
  * curl, bash and python - for running and analyzing Bullet queries

## Measuring the inherent latency of Bullet

This test runs with the [standard configuration](#configuration) above.

We are [running this query](../ws/examples.md#simplest-query) in this test. While not particularly a common query normal users would run, this ```RAW``` query without any filters will serve to measure the intrinsic delay added by Bullet. Since the data record pulled out has a timestamp for when the record was emitted into Kafka and Bullet will inject the timestamp into the record when the Filter bolt receives it and the metadata collection log timestamps for when the query was received and terminated, we can measure the end-to-end latency for getting one record through Bullet. We can also use the timestamp of query submission to determine what the end-to-end latency of getting a query through Bullet.

The following table shows the timestamps averaged by running **100** of these queries. The delays below are shown *relative* to the Query Received timestamp (when the query was received by Bullet at the Join bolt).

<div class="mostly-numeric-table"></div>

|    Timestamp    | Delay (ms) |
| :-------------- | ---------: |
| Kafka Received  | -705.79    |
| Bullet Received | -1.01      |
| Query Received  | 0          |
| Query Finished  | 1.74       |

This table shows that Bullet adds a delay of ```1.74 ms``` to just pull out a record. Note that the Bullet Received timestamp above is negative. This is because the Filter bolt received the query and emitted an arbitrary record ```1.01 ms``` before the Join bolt received the query. The data was submitted into Kafka about ```705.79 ms``` before the query was received by Bullet and that difference is the processing time of Kafka and the time for our spouts to read the data into Bullet.

This result shows that this is the fastest Bullet can be. It cannot return data any faster than this for meaningful queries.

## Measuring the time to find a record

This test runs with the [standard configuration](#configuration) above.

The [last test](#measuring-the-inherent-latency-of-bullet) attempted to measure how long Bullet takes to pick out a record. Here we will measure how long it takes to find a record *that we generate*. This is the average of running **100** queries across a time interval of 30 minutes trying to filter for a record with a single unique value in a field [similar to this query](../ws/examples.md#simple-filtering).

Since this query actually requires us to be looking at the values in the data, we should also mention that the average data volume across this test was: ```Data: 164,000 MPS and 107 MB/s```

<div class="mostly-numeric-table"></div>

|    Timestamp    | Delay (ms) |
| :-------------- | ---------: |
| Kafka Received  | 519.25     |
| Bullet Received | 1161.43    |
| Query Received  | 0          |
| Query Finished  | 1165.96    |

Now, we're getting somewhere! We see that Bullet took on average ```1165.96 ms - 1161.43 ms = 4.53 ms``` from the time it saw the record in the Filter bolt to finishing up the query and returning it. Notice that the record was emitted into Kafka ```519.25 ms``` after the query was received. The delay is the time it takes for the generated record to flow through our network and into Kafka.

It is difficult to isolate how long of the ```1161.43 ms - 519.25 ms = 642.18 ms``` was spent in Kafka and how long was spent reading the record and sending it to the Filter bolt from our spout. However, we can look this time as a whole and include it into the time to get data into Bullet.

!!! note "So, Bullet takes ~5 ms to find a record?"

    No, not really. Remember that we are only including the time from which the record was matched in the Filter bolt to when it was sent out from the Join bolt. We can only conclude that the true delay is less than ```1165.96 ms - 519.25 ms = 646.71 ms``` because that is the difference in time from when the record was emitted into Kafka and when it was emitted out of Bullet. It is less than that because a part of that time is Kafka accepting the record and making it available for consumption. Nevertheless, finding a single record in data stream of ```164,000 mps``` in about half a second with about [5 machines](#resource-utilization) is not bad at all!

# More coming soon!
