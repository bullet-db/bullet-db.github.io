# Tuning Bullet in Storm

The performance of a Bullet instance running on a multi-tenant Storm cluster has a lot of independent variables that we could vary and have an effect including:

1. The amount of data we consume
2. The number of simultaneous queries Bullet runs
3. The kinds of simultaneous queries - ```RAW```, ```GROUP```, ```COUNT DISTINCT```, etc.
4. Varying parallelisms of the components - increase the parallelisms of Filter bolts disproportionately to others
5. The hardware configuration of machines
6. The various Storm versions
7. How free the cluster is and the kinds of topologies running on the cluster - CPU heavy, Disk/memory heavy, network heavy etc
8. The source of the data and tuning consumption from it

...and many more.

As a streaming system, the two main features to measure is how much data it operates on and how many queries can you run simultaneously (1 and 2 above).

!!! note "Not a benchmark"

    We will focus on 1 and 2, while keeping the others as fixed as possible. This section is to give you some insight as to what to tune to improve performance. This is not meant to be a rigorous benchmark.

## Prerequisites

You should be familiar with [Storm](http://storm.apache.org), [Kafka](http://kafka.apache.org) and the [Bullet on Storm architecture](storm-architecture.md).

##  How was this tested?

All tests run here were using [Bullet-Storm 0.4.2](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.4.2). We are working with just the Storm piece without going through the Web Service or the UI. The DRPC REST endpoint provided by Storm lets us do just that.

Using the pluggable metrics interface in Bullet on Storm, we captured worker level metrics such as CPU time, Heap usage, GC times and types, sent them to a in-house monitoring service for time-slicing and graphing. The figures shown below use this service. See [0.3.0](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.3.0) for how to plug in your own metrics collection.

### Cluster

* Running a custom build of Storm - Storm 0.10.2 with Storm 1.0+ features backported. For all intents and purposes, it's Storm 1.0.3
* The spec for the machines we were running on:
    - 2 x Intel E5-2680v3 (12 core, 24 threads) - One reserved core gives each machine 47 cores from the Storm scheduler point of view
    - 256 GB RAM
    - 4 TB SATA Disk
    - 10 G Network Interface
* Multi-tenant cluster with other topologies running. Average cluster utilization ranged from *70% - 90%*

### Data

* Reading from a Kafka 0.9.0.1 topic partitioned into 64 partitions
* The Kafka cluster was located within the same datacenter as the Storm cluster - close network proximity gives us some measure of confidence that large data transmission delays aren't a factor.
* The data records or messages per second (mps) for the topic was 43,000 mps to 104,000 mps with an average of 72,000 mps
* The compressed data output of the topic was 22 MB/s to 128 MB/s with an average of 78 MB/s. Compressed data is roughly 80% the size of the uncompressed data

Since there is variance in the volume of data over time, for each of the tests below, the data volume at that time will be provided in this format: ```Data: XX MPS and XX MB/s``` , where each of the numbers are the average for each metric over the hour of when the test was done.

### Configuration

Here is the default configuration we used to launch the basic instance of Bullet on Storm:

```YAML
bullet.topology.metrics.enable: true
bullet.topology.metrics.built.in.enable: true
bullet.topology.metrics.built.in.emit.interval.mapping:
   bullet_active_queries: 5
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
bullet.topology.filter.bolt.memory.on.heap.load: 384.0
bullet.topology.filter.bolt.memory.off.heap.load: 192.0
bullet.topology.return.bolt.parallelism: 1
bullet.topology.return.bolt.cpu.load: 20.0
bullet.topology.return.bolt.memory.on.heap.load: 128.0
bullet.topology.return.bolt.memory.off.heap.load: 192.0
bullet.topology.join.bolt.parallelism: 2
bullet.topology.join.bolt.cpu.load: 50.0
bullet.topology.join.bolt.memory.on.heap.load: 384.0
bullet.topology.join.bolt.memory.off.heap.load: 192.0
bullet.topology.join.bolt.error.tick.timeout: 3
bullet.topology.join.bolt.query.tick.timeout: 3
bullet.topology.tick.interval.secs: 1
bullet.query.default.duration: 30000
bullet.query.max.duration: 540000
bullet.query.aggregation.max.size: 512
bullet.query.aggregation.raw.max.size: 500
bullet.query.aggregation.distribution.max.points: 200
```
Any setting not listed here default to the defaults in [bullet_defaults.yaml](https://github.com/yahoo/bullet-storm/blob/bullet-storm-0.4.2/src/main/resources/bullet_defaults.yaml). In particular, **metadata collection** and **timestamp injection** is enabled. ```RAW``` type queries also micro-batch by size 1 (in other words, do not micro-batch).

The topology was also launched (command-line args to Storm) with the following Storm settings:

```bash
storm jar
    ...
    --bullet-spout-parallelism 64
    --bullet-spout-cpu-load 100.0 \
    --bullet-spout-on-heap-memory-load 768.0 \
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
4. We have set the max heap size for a worker to ```4 GiB``` since we do not want too large of a worker. If a component dies or a worker is killed by RAS, it will not affect too many other components. It also makes heap dumps etc manageable.
5. We set ```topology.worker.gc.childopts``` to use ```ParNewGC``` and ```CMS```. These are our cluster defaults but we are listing them here since this may not be true for all Storm clusters. We have also added the ```-XX:NewRatio=1``` to the defaults since most of our objects are short-lived and having a larger Young Generation reduces our Young Generation GC (ParNew) frequency.
6. We are using 256 acker tasks. There is acking from the DataSource spout to the Filter bolt and from the DRPCSpout and the PrepareRequestBolt, so about ~130 components will be acking. We could get away with using much less ackers as they are very light-weight.

### Resource utilization

<div class="mostly-numeric-table"></div>

|     Component       | Parallelism |CPU (cores) | Total Memory (MB) |
| :------------------ | ----------: | ---------: | ----------------: |
| DataSource Spout    |64           |64          | 61440             |
| Filter Bolt         |128          |128         | 73728             |
| Join Bolt           |2            |1           | 1152              |
| DRPC Spout          |2            |0.4         | 640               |
| PrepareRequest Bolt |1            |0.2         | 320               |
| ReturnResults Bolt  |1            |0.2         | 320               |
| IMetricsConsumer    |1            |0.1         | 128               |
| Ackers              |256          |25.6        | 32768             |
| **Total**           |**455**      |**219.5**   | **170496**        |

With these ~47 virtual core machines, we would need ```5``` of these machines to run this instance of Bullet reading this data source and supporting a certain number of queries. What this certain number is, we will determine below.

### Tools used

  * [jq](https://stedolan.github.io/jq/) - a nice tool to parse Bullet JSON responses
  * curl, bash and python - for running and analyzing Bullet queries

## Test 1: Measuring the minimum latency of Bullet

This test runs with the [standard configuration](#configuration) above.

We are [running this query](../ws/examples.md#simplest-query) in this test. This ```RAW``` query without any filters will serve to measure the intrinsic delay added by Bullet. The data record pulled out has a timestamp for when the record was emitted into Kafka, Bullet will inject the timestamp into the record when the Filter bolt sends it on and the metadata collection logs timestamps for when the query was received and terminated. Using these, we can measure the end-to-end latency for getting one record through Bullet.

### Result

The following table shows the timestamps averaged by running **100** of these queries. The delays below are shown *relative* to the Query Received timestamp (when the query was received by Bullet at the Join bolt).

<div class="mostly-numeric-table"></div>

|    Timestamp    | Delay (ms) |
| :-------------- | ---------: |
| Kafka Received  | -710.75    |
| Bullet Filtered | -2.16      |
| Query Received  | 0          |
| Query Finished  | 1.66       |

The Bullet Filtered timestamp above is negative because the Filter bolt received the query and emitted an arbitrary record ```2.16 ms``` before the Join bolt received the query. The data was submitted into Kafka about ```710.75 ms``` before the query was received by Bullet and that difference is the processing time of Kafka and the time for our spouts to read the data into Bullet.

### Conclusion

Bullet adds a delay of a few ms - **```1.66 ms```** in the test above - to just pull out a record. This result shows that this is the fastest Bullet can be. It cannot return data any faster than this for meaningful queries.

## Test 2: Measuring the time to find a record

This test runs with the [standard configuration](#configuration) above.

The [last test](#test-1-measuring-the-minimum-latency-of-bullet) attempted to measure how long Bullet takes to pick out a record. Here we will measure how long it takes to find a record *that we generate*. This is the average of running **100** queries across a time interval of 30 minutes trying to filter for a record with a single unique value in a field [similar to this query](../ws/examples.md#simple-filtering).

We added a timestamp into the record when the record was initially read by the DataSource spout. Using this and the Bullet Filtered timestamp and Query Finished timestamps, we can easily track the record through Bullet.

Since we are looking at values in the data, the average data volume across this test was: ```Data: 76,000 MPS and 101 MB/s```

### Result

<div class="mostly-numeric-table"></div>

|    Timestamp    | Delay (ms) |
| :-------------- | ---------: |
| Kafka Received  | 445.7      |
| Bullet Received | 996.5      |
| Bullet Filtered | 1003.3     |
| Query Received  | 0          |
| Query Finished  | 1006.8     |

The record was emitted into Kafka ```445.81 ms``` after the query was received. The delay is the time it takes for the generated record to flow through our network and into Kafka.

Bullet received the record ```996.5 ms``` after the query was received. The delay from when Kafka received the record to Bullet received is the delay for Kafka to make the record available for reading.

### Conclusion

We see that Bullet took on average ```1006.8 ms - 996.5 ms``` or **```10.3 ms```** from the time it saw the record first in Spout to finishing up the query and returning it in the Join bolt.

## Test 3: Measuring the maximum number of parallel ```RAW``` queries

This test runs with the [standard configuration](#configuration) above.

This test runs a query similar to the [simple filtering query](../ws/examples.md#simple-filtering). The query looks for ```10``` records that match the filter or runs for ```30``` seconds, whichever comes first. The average, uncompressed record size was about ```1.8 KiB```.

### What is meant by maximum?

We want to see how many of these queries we can have running simultaneously till the Filter bolt is unable to process records from the spouts in time. For example, if we have 1000 queries running at once, each data record in the Filter bolt will be operated on by all the 1000 queries. If a Filter bolt is unable to keep up with the rate of data produced by the spouts, our queries will not find all 10 records. Workers may start dying (killed by RAS for exceeding capacity) as well. We will be trying to find the number of queries in parallel that we can run without these happening.

The average data volume across this test was: ```Data: 85,000 MPS and 126 MB/s```

### Query

```javascript
{
 "filters" : [
              {"field" : "id", "operation" : "==", "values": ["c39ba8cfe8"]}
             ],
 "aggregation" : {"type" : "LIMIT", "size" : 10},
 "duration" : 30000
}
```

We will run a certain number of these queries then generate records matching this query. We will validate that we have all 10 records for all queries at the end.

### Script

This script takes in a single numeric argument to run a number of queries in parallel (you may have to use ```ulimit``` to change maximum user processes if you specify a large number). It runs till you kill it performing the following:

1. It generates a provided number of the [query above](#query) and runs them in parallel against a randomly chosen DRPC server
2. It generates data for the query
3. It waits out the rest of the time and uses jq to validate that all the generated data was found

Here is a version of the script with the specifics to our data generation and Storm topology removed:

```bash
#! /bin/bash

SERVERS=("drpc_server_1" "drpc_server_2" "drpc_server_3")
NUM_QUERIES=$1
NUM_RESULTS=10

mkdir -p results

ATTEMPT=0

echo -e "Running $NUM_QUERIES queries and generating $NUM_RESULTS results..."

while true; do
    rm results/*.json
    ps aux | grep [c]url | awk '{print $2}' | xargs kill

    ((ATTEMPT++))
    echo -e "\nAttempt: $ATTEMPT"
    for i in `seq 1 $NUM_QUERIES`; do
        echo -en "\rRunning query $i/$NUM_QUERIES..."
        SERVER=${SERVERS[$RANDOM % 3]}
        curl -s -X POST -d @queries/query.json $SERVER:4080/drpc/function > results/result_$i.json &
    done

    # Sleep for a bit to make sure the queries have reached Bullet
    sleep 10

    echo ""
    for i in `seq 1 $NUM_RESULTS`; do
            # Run curl to generate result
            echo -en "\rGenerating result $i/$NUM_RESULTS..."
    done

    # Sleep for the query duration
    sleep 20
    # Sleep 3 seconds to make sure results are emitted after 3 ticks (1 s each) : if all records were not found
    sleep 3

    COUNTS=`jq '.records | length' ./results/result_*.json | sort | uniq -c`

    echo -e "\n$COUNTS"

    TRIMMED=`echo "$COUNTS" | xargs`
    if [ "$TRIMMED" == "$NUM_QUERIES $NUM_RESULTS" ]; then
        echo "Passed!"
    else
        echo "Failed!"
    fi
done
```

### Result

For this configuration, we were able to run 200 queries successfully but 300 and higher started causing our Filter bolts to slow down. This slow down caused our spouts to be throttled and fall behind reading data. This caused the matching data to not show up in time during the queries. Some of our attempts would not return all the expected 10 records.

Using our metrics that were captured using our in-house metrics aggregation system (that our IMetricsConsumer publishes to), let's take a look at the CPU, Heap utilizations.

Before you look at the figures:

1. All the figures below are for the same time interval. The X-axis represents time in ```1 minute``` intervals
2. [Figure 1](#figure-1-queries-running) shows the number of queries running for a time interval
3. The other figures show a metric across **all** the workers (JVMs) in the Storm topology, each running a mix of a components (spouts running from Kafka, Filter bolts etc)
4. The majority of the components (excluding ackers) are spouts reading from Kafka or Filter bolts, so the figures can be taken to be primarily describing those workers

#### Figure 1. Queries running
![Queries](../img/raw-perf-queries.png)

#### Figure 2. CPU user-time usage
![CPU Utilization](../img/raw-perf-cpu.png)

#### Figure 3. On Heap usage
![Heap Utilization](../img/raw-perf-heap.png)

#### Figure 4. Garbage Collection times
![GC Time](../img/raw-perf-gc.png)

[Figure 1](#figure-1-queries-running) shows that we first ran 100 queries, then 200, then 400 and finally 300. The numbers go over their target because we only added a 2 s buffer in our script. Network and tick delays caused some queries to not be entirely purged before the next set of N simultaneous queries came in.

[Figure 2](#figure-2-cpu-user-time-usage) shows the milliseconds of CPU time used per minute. For example, a value of ```300K ms``` ms for a line (worker) means that the worker used ```300K ms/min```  or ```300s/60s``` or ```5``` CPU cores (virtual) in that minute.

[Figure 3](#figure-3-on-heap-usage) shows raw numbers for Heap utilizations in bytes.

[Figure 4](#figure-4-garbage-collection-times) shows the time spent garbage collecting in ms.

!!! note "Garbage collection"

    As we increase the number of queries sent into Bullet, more objects are created in the Filter and Join bolts. These quickly fill up our heap and cause GCs. The zig-zags represents heaps being cleared after GC and filling back up quickly. Also, note that the CPU usage is directly related to the GC times. In other words, performance is pretty much directly correlated with the amount of GC we do.

The following table summarizes these figures:

<div class="mostly-numeric-table"></div>

|  Simultaneous Queries  | Average CPU (ms)| Average Result size |
| :--------------------- | --------------: | ------------------: |
| 0                      |90K              | N/A                 |
| 100                    |130K             | 10                  |
| 200                    |170K             | 10                  |
| 300                    |230K             | 8.9                 |
| 400                    |270K             | 7.3                 |

### Conclusion

We are able to run somewhere between 200 and 300 ```RAW``` queries simultaneously before losing data.

## Test 4: Improving the maximum number of simultaneous ```RAW``` queries

The [last test](#test-3-measuring-the-maximum-number-of-parallel-raw-queries) showed us that the [standard configuration](#configuration) lets us run somewhere from 200 and 300 ```RAW``` queries. Let's improve that. The [GC times](#figure-4-garbage-collection-times) and the [heap usage](#figure-3-on-heap-usage) tell us that a larger heap may help. Also, since each of our machines has 256 GB of RAM and we have a lot of unused heap being wasted per machine (since we use up all the CPU cores), we can be use a lot more heap and not have to GC so much. Let's also try to make the worker even leaner by decreasing the max worker size so that slow components don't block others.

Changes:

```
-bullet.topology.filter.bolt.memory.on.heap.load: 384.0
+bullet.topology.filter.bolt.memory.on.heap.load: 1024.0

- --bullet-spout-on-heap-memory-load 768.0 \
+ --bullet-spout-on-heap-memory-load 1280.0 \

- -c topology.worker.max.heap.size.mb=4096.0 \
+ -c topology.worker.max.heap.size.mb=3072.0 \
```

Our resource utilization is now:

<div class="mostly-numeric-table"></div>

|     Component       | Parallelism |CPU (cores) | Total Memory (MB) |
| :------------------ | ----------: | ---------: | ----------------: |
| DataSource Spout    |64           |64          | 94208             |
| Filter Bolt         |128          |128         | 155648            |
| Join Bolt           |2            |1           | 1152              |
| DRPC Spout          |2            |0.4         | 640               |
| PrepareRequest Bolt |1            |0.2         | 320               |
| ReturnResults Bolt  |1            |0.2         | 320               |
| IMetricsConsumer    |1            |0.1         | 128               |
| Ackers              |256          |25.6        | 32768             |
| **Total**           |**455**      |**219.5**   | **285184**        |

Our data volume across this test was: ```Data: 84,000 MPS and 124 MB/s```

### Result

With this configuration, we were able to run 700 queries simultaneously and failed at some where between 700 and 800. See below for why.

We notice that the GC times have improved a lot (down to ~12K ms from ~35K ms in [Figure 4](#figure-4-garbage-collection-times)). While our overall CPU usage seems to have gone down since we GC a lot less, remember that our changes to the maximum worker size makes our workers run less components and as a result, use less CPU. This is why there are more lines overall (more workers).

#### Figure 5. Queries running
![Queries](../img/raw-perf-2-queries.png)

#### Figure 6. CPU user-time usage
![CPU Utilization](../img/raw-perf-2-cpu.png)

#### Figure 7. On Heap usage
![Heap Utilization](../img/raw-perf-2-heap.png)

#### Figure 8. Garbage Collection times
![GC Time](../img/raw-perf-2-gc.png)

<div class="mostly-numeric-table"></div>

|  Simultaneous Queries  | Average CPU (ms)| Average Result size |
| :--------------------- | --------------: | ------------------: |
| 0                      |50K              | N/A                 |
| 300                    |80K              | 10                  |
| 500                    |95K              | 10                  |
| 600                    |100K             | 10                  |
| 700                    |100K             | 10                  |
| 735                    |105K             | 10                  |
| 800                    |105K             | 9.19                |

We seem to cap out at 735 queries. This is actually due how the blocking implementation of Storm DRPC works. Storm DRPC currently dedicates a thread to each DRPC request and does not allow more requests till they are finished. For Bullet, when we ran 800 queries for the test, only the first 735 would even be sent to Bullet. The rest 65 would be sent after some of the first return but all of those 65 would return 0 records because the data that they are looking for had long since been processed. We had ```3``` DRPC servers in the cluster and you could *scale by adding more of these*.

### Conclusion

With this change in heap usage, we could get to **```735```** of these queries simultaneously without any issues. We could do more but were limited by the number of DRPC servers in our cluster.

!!! note "735 is a hard limit then?"

    This is what our Storm cluster's configuration limits us to. There is an async implementation for DRPC that we could eventually switch to. Also, an alternative to DRPC - such as using a Pub/Sub queue like Kafka to deliver queries and retrieve results from Bullet - may be required anyway to implement Bullet on other Stream Processors.

## Test 5: Scaling for Data

For this test, we upgraded our Kafka cluster to **Kafka 0.10.0.1** and used the new Kafka consumer APIs to read *batches* of messages instead of a message at a time. We changed our DataSource spout to read batches of messages (raw bytes) instead and added a DataSource bolt that converts each batch message into Bullet records.

To read more data, we will be trying to read a topic that is a superset of our data set so far and produces up to **13** times the number of records (maximum of 1.3 million records/sec) and **20** times the size of the data we were reading till now. This Kafka topic has **256** partitions.

Our average data volume across this test was: ```Data: 756,000 MPS and 3080 MB/s```

<div class="mostly-numeric-table"></div>

|     Component       | Parallelism |CPU (cores) | Total Memory (MB) |
| :------------------ | ----------: | ---------: | ----------------: |
| DataSource Spout    |128          |128         | 155648            |
| DataSource Bolt     |256          |512         | 709632            |
| Filter Bolt         |512          |512         | 622592            |
| Join Bolt           |2            |1           | 1408              |
| DRPC Spout          |2            |0.4         | 640               |
| PrepareRequest Bolt |1            |0.2         | 320               |
| ReturnResults Bolt  |1            |0.2         | 320               |
| IMetricsConsumer    |4            |0.4         | 512               |
| Ackers              |256          |25.6        | 32768             |
| **Total**           |**1162**      |**1179.8**   | **1523840**     |

In terms of [our machines](#cluster), the CPU is clearly the limiting factor. We end up using about **25** machines to run this topology.

We also tweaked our GC and Storm settings. We ran the topology with the following command:

```bash
storm jar
          ...
          --bullet-conf bullet_settings.yaml \
          -c topology.max.spout.pending=30 \
          -c topology.backpressure.enable=false \
          -c topology.acker.executors=256 \
          -c topology.component.resources.onheap.memory.mb=128.0 \
          -c topology.worker.max.heap.size.mb=3072.0 \
          -c topology.worker.gc.childopts="-XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:NewSize=128m -XX:NewRatio=2 -XX:SurvivorRatio=6 -XX:+UseCMSInitiatingOccupancyOnly -XX:-CMSConcurrentMTEnabled -XX:CMSInitiatingOccupancyFraction=50 -XX:ParallelGCThreads=8 -XX:ConcGCThreads=4" \
          ...
```

We capped the GC threads to ```8``` and ```4```, which helps performance on our 48 core machines when multiple JVMs run on a machine. We also bumped up the Young Generation size (```NewRatio=2```) and triggered the CMS collection to run at ```50%``` of Old Generation instead of the default of ```70%```. Our objects are short-lived in our streaming scenario, this makes sense. We arrived at this after a few iterations, which we'll skip here for brevity.

!!! note "Max Spout Pending is 30 ?!"

    We use ```topology.max.spout.pending``` as a way to throttle how fast we read from Kafka. There is no acking past the Filter bolt. The maximum number of batch messages we read is ```500``` from Kafka. This makes our true max spout pending: ```500 * 30 = 15,000```. The tuple that is emitted from the spout is a large tuple that contains up to ```500``` records and we limit up to ```30``` of those to go unacked from any single spout before we throttle it. Since we have ```128``` spouts, we can have ```128 * 15,000``` messages unacked in the topology at any time at the most.

### Result

We were able to run over 600 queries with this configuration and failed in the high 600s due to hitting the DRPC limit again. With our improved reading model and GC configs, our base resource footprint has improved from ```50K``` CPU ms/min to around ```25K``` CPU ms/min.

#### Figure 9. Queries running
![Queries](../img/raw-perf-3-queries.png)

#### Figure 10. CPU user-time usage
![CPU Utilization](../img/raw-perf-3-cpu.png)

#### Figure 11. On Heap usage
![Heap Utilization](../img/raw-perf-3-heap.png)

#### Figure 12. Garbage Collection times
![GC Time](../img/raw-perf-3-gc.png)

<div class="mostly-numeric-table"></div>

|  Simultaneous Queries  | Average CPU (ms)| Average Result size |
| :--------------------- | --------------: | ------------------: |
| 0                      |25K              | N/A                 |
| 100                    |35K              | 10                  |
| 300                    |60K              | 10                  |
| 500                    |85K              | 10                  |
| 600                    |90K              | 10                  |
| 680                    |95K              | 10                  |
| 700                    |95K              | 9.79                |

Note that the drops when we were running simultaneous queries in [Figure 9](#figure-9-queries-running) are due to some
hiccups in our collection mechanism (the collection granularity was not 5s as we configured but higher) and not actually drops in the simultaneous queries.

### Conclusion

We are trying to read a data source that could have```13``` times more records and ```20``` times more data volume. So we have roughly increased the parallelism of the components reading the data by 10x (```128 + 512 = 768``` cores to read and convert the data whereas previously we were using ```64``` cores). Once this is fixed and we can read the data comfortably using our DataSource spouts and bolts, we can scale the Filter bolts and other components to accommodate for queries. We set our Filter bolt parallelism (dominates the rest of the components) to ```512```. We need about ```25``` machines (5 times more than the previous of ```5```).

With this configuration, we were able to run **```680```** queries simultaneously before we hit the DRPC limit. Since DRPC is a shared resource for the cluster, this limit is slightly lower than the previously observed number possibly due to our test environment being multi-tenant and other topologies using the shared resource.
