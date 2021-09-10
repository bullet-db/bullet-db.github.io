# Releases

This sections gathers all the relevant releases of the components of Bullet that we maintain in one place. It may not include the very few initial releases of these components if they were largely irrelevant. Full release notes can be found by clicking on the actual releases.

Bullet is still in active development. We welcome all contributions. Feel free to raise any issues/questions/bugs and whatever else on the relevant issues section for each component. Please include as many details as you can.

## API Documentation

API (Java and Scala) docs can also be found for the releases below.

## Download

For downloading any of the latest artifacts listed below, you should use [Maven Central](https://repo1.maven.org/maven2/com/yahoo/bullet/). For resolving artifacts in your build tool, follow the directions in each of the components' Package Manager Setup sections.

### Maven central

Our current package management solution is Maven Central. This requires no configuration if using Maven. The various releases below are not entirely on Maven Central. Certain older versions are on our previous package management solution.

### JCenter

JCenter was sunset in July 2021. All our artifacts prior to ~June 2021 that were on JCenter will still be accessible as long as [JCenter is in read-only mode](https://jfrog.com/blog/into-the-sunset-bintray-jcenter-gocenter-and-chartcenter/). We have since moved to Maven Central and artifacts since June 2021 are being published there. If you wish to resolve JCenter artifacts, you will need to configure your package manager to use JCenter. For instance, to resolve JCenter artifacts in Maven, you will need to add:

```xml
<repositories>
    <repository>
        <snapshots>
            <enabled>false</enabled>
        </snapshots>
        <id>central</id>
        <name>bintray</name>
        <url>http://jcenter.bintray.com</url>
    </repository>
</repositories>

```

-----

## Bullet Core

The core Bullet logic (a library) that can be used to implement Bullet on different Stream Processors (like Flink, Storm, Kafka Streams etc.). This core library can also be reused in other Bullet components that wish to depend on core Bullet concepts. This actually lived inside the [Bullet Storm](#bullet-storm) package prior to version [0.5.0](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.5.0). Starting with 0.5.0, Bullet Storm only includes the logic to implement Bullet on Storm.

|                           |                 |
| ------------------------- | --------------- |
| **Repository**            | [https://github.com/bullet-db/bullet-core](https://github.com/bullet-db/bullet-core) |
| **Issues**                | [https://github.com/bullet-db/bullet-core/issues](https://github.com/bullet-db/bullet-core/issues) |
| **Last Tag**              | [![Latest tag](https://img.shields.io/github/release/bullet-db/bullet-core/all.svg)](https://github.com/bullet-db/bullet-core/tags) |
| **Latest Artifact**       | [![Latest Artifact](https://maven-badges.herokuapp.com/maven-central/com.yahoo.bullet/bullet-core/badge.svg)](https://maven-badges.herokuapp.com/maven-central/com.yahoo.bullet/bullet-core) |
| **Package Manager Setup** | [Maven Central](https://search.maven.org/artifact/com.yahoo.bullet/bullet-core/${bullet.core.version}/jar) |

### Releases

|    Date      |                                        Release                                        |        JCenter        |      Maven Central    | Highlights | APIDocs |
| ------------ | ------------------------------------------------------------------------------------- | :-------------------: | :-------------------: | ---------- | ------- |
| 2021-08-26   | [**1.5.0**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-1.5.0)  |                       | <span>&#10003;</span> | Outer queries (subqueries and nested LATERAL VIEW EXPLODE | [JavaDocs](apidocs/bullet-core/1.5.0/index.html) |
| 2021-08-02   | [**1.4.4**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-1.4.4)  |                       | <span>&#10003;</span> | More efficient BOOLEAN computation and efficient LATERAL VIEW | [JavaDocs](apidocs/bullet-core/1.4.4/index.html) |
| 2021-07-30   | [**1.4.3**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-1.4.3)  |                       | <span>&#10003;</span> | UNKNOWN containers as first class with Bullet Record 1.2.0 | [JavaDocs](apidocs/bullet-core/1.4.3/index.html) |
| 2021-06-30   | [**1.4.2**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-1.4.2)  |                       | <span>&#10003;</span> | Uses Bullet Record 1.1.4 with better Avro performance | [JavaDocs](apidocs/bullet-core/1.4.2/index.html) |
| 2021-06-25   | [**1.4.1**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-1.4.1)  |                       | <span>&#10003;</span> | ByteArrayPubSubMessageSerDe | [JavaDocs](apidocs/bullet-core/1.4.1/index.html) |
| 2021-06-23   | [**1.4.0**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-1.4.0)  |                       | <span>&#10003;</span> | PubSubMessage stores Serializable. PubSubMessageSerDe infrastructure | [JavaDocs](apidocs/bullet-core/1.4.0/index.html) |
| 2021-06-03   | [**1.3.2**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-1.3.2)  |                       | <span>&#10003;</span> | MOD, LOWER, UPPER | [JavaDocs](apidocs/bullet-core/1.3.2/index.html) |
| 2021-05-13   | [**1.3.1**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-1.3.1)  |                       | <span>&#10003;</span> | Bug fix for BulletConfig not recreating the BulletRecordProvider | [JavaDocs](apidocs/bullet-core/1.3.1/index.html) |
| 2021-05-05   | [**1.3.0**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-1.3.0)  |                       | <span>&#10003;</span> | Rate limited BufferingSubscriber, EXPLODE, LATERAL VIEW, NOT RLIKE, NOT RLIKE ANY, TRIM, ABS, BETWEEN, NOT BETWEEN, SUBSTRING, UNIXTIMESTAMP | [JavaDocs](apidocs/bullet-core/1.3.0/index.html) |
| 2021-04-27   | [**1.2.3**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-1.2.3)  |                       | <span>&#10003;</span> | First release using Screwdriver | [JavaDocs](apidocs/bullet-core/1.2.3/index.html) |
| 2021-04-22   | [**1.2.2**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-1.2.2)  |                       | <span>&#10003;</span> | First release on Maven Central | [JavaDocs](apidocs/bullet-core/1.2.2/index.html) |
| 2021-03-24   | [**1.2.1**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-1.2.1)  | <span>&#10003;</span> |                       | YAML library is snakeyaml instead of jvyaml | [JavaDocs](apidocs/bullet-core/1.2.1/index.html) |
| 2021-01-04   | [**1.2.0**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-1.2.0)  | <span>&#10003;</span> |                       | Storage layer updates and extensions | [JavaDocs](apidocs/bullet-core/1.2.0/index.html) |
| 2020-10-30   | [**1.1.0**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-1.1.0)  | <span>&#10003;</span> |                       | Ternary Logic, Bullet Record 1.1 | [JavaDocs](apidocs/bullet-core/1.1.0/index.html) |
| 2020-10-02   | [**1.0.0**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-1.0.0)  | <span>&#10003;</span> |                       | Major release - Expressions, Storage, Async queries, No JSON queries | [JavaDocs](apidocs/bullet-core/1.0.0/index.html) |
| 2019-02-01   | [**0.6.6**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.6.6)  | <span>&#10003;</span> |                       | QueryManager partition leak cleanup | [JavaDocs](apidocs/bullet-core/0.6.6/index.html) |
| 2018-12-20   | [**0.6.5**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.6.5)  | <span>&#10003;</span> |                       | QueryManager logging fixes | [JavaDocs](apidocs/bullet-core/0.6.5/index.html) |
| 2018-11-21   | [**0.6.4**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.6.4)  | <span>&#10003;</span> |                       | Extended field extraction in Projections | [JavaDocs](apidocs/bullet-core/0.6.4/index.html) |
| 2018-11-21   | [**0.6.3**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.6.3)  | <span>&#10003;</span> |                       | Extended field extraction Filters and Aggregations | [JavaDocs](apidocs/bullet-core/0.6.3/index.html) |
| 2018-11-19   | [**0.6.2**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.6.2)  | <span>&#10003;</span> |                       | Query Manager helpers | [JavaDocs](apidocs/bullet-core/0.6.2/index.html) |
| 2018-11-16   | [**0.6.1**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.6.1)  | <span>&#10003;</span> |                       | Query Categorizer category | [JavaDocs](apidocs/bullet-core/0.6.1/index.html) |
| 2018-11-06   | [**0.6.0**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.6.0)  | <span>&#10003;</span> |                       | Query Partitioning, Validator and other improvements | [JavaDocs](apidocs/bullet-core/0.6.0/index.html) |
| 2018-10-21   | [**0.5.2**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.5.2)  | <span>&#10003;</span> |                       | AutoCloseable Pubsub Components, HttpClient 4.3.6 | [JavaDocs](apidocs/bullet-core/0.5.2/index.html) |
| 2018-09-25   | [**0.5.1**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.5.1)  | <span>&#10003;</span> |                       | Better Order By, Smaller Serializations, Transient Fields | [JavaDocs](apidocs/bullet-core/0.5.1/index.html) |
| 2018-09-14   | [**0.5.0**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.5.0)  | <span>&#10003;</span> |                       | Post Aggregations - ORDER BY, COMPUTATION, Casting in Filters | [JavaDocs](apidocs/bullet-core/0.5.0/index.html) |
| 2018-09-05   | [**0.4.3**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.4.3)  | <span>&#10003;</span> |                       | Sliding Windows, SIZEIS, CONTAINSKEY, CONTAINSVALUE, filtering against other fields | [JavaDocs](apidocs/bullet-core/0.4.3/index.html) |
| 2018-06-26   | [**0.4.2**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.4.2)  | <span>&#10003;</span> |                       | Fixes a bug with unclosed connections in the RESTPubSub | [JavaDocs](apidocs/bullet-core/0.4.2/index.html) |
| 2018-06-22   | [**0.4.1**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.4.1)  | <span>&#10003;</span> |                       | Added RESTPublisher HTTP Timeout Setting | |
| 2018-06-18   | [**0.4.0**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.4.0)  | <span>&#10003;</span> |                       | Added support for Integer and Float data types, and configurable BulletRecordProvider class used to instantiate BulletRecords in bullet-core | |
| 2018-04-11   | [**0.3.4**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.3.4)  | <span>&#10003;</span> |                       | Pre-Start delaying and Buffering changes - queries are now buffered at the start of a query instead of start of each window | |
| 2018-03-30   | [**0.3.3**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.3.3)  | <span>&#10003;</span> |                       | Bug fix for com.yahoo.bullet.core.querying.Querier#isClosedForPartition | |
| 2018-03-20   | [**0.3.2**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.3.2)  | <span>&#10003;</span> |                       | Added headers to RESTPubSub http requests | |
| 2018-03-16   | [**0.3.1**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.3.1)  | <span>&#10003;</span> |                       | Added RESTPubSub implementation | |
| 2018-02-22   | [**0.3.0**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.3.0)  | <span>&#10003;</span> |                       | Supports windowing / incremental updates | |
| 2017-10-04   | [**0.2.5**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.2.5)  | <span>&#10003;</span> |                       | Supports an in-memory BufferingSubscriber implementation for reliable subscribing | |
| 2017-10-03   | [**0.2.4**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.2.4)  | <span>&#10003;</span> |                       | Helpers added to Config, PubSubMessage, Metadata and JSONFormatter. FAIL signal in Metadata. PubSubMessage is JSON serializable | |
| 2017-09-20   | [**0.2.3**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.2.3)  | <span>&#10003;</span> |                       | PubSub is no longer required to be Serializable. Makes PubSubMessage fully serializable. Utility classes and checked exceptions for PubSub | |
| 2017-08-30   | [**0.2.2**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.2.2)  | <span>&#10003;</span> |                       | Helper methods to PubSubMessage and Config | |
| 2017-08-23   | [**0.2.1**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.2.1)  | <span>&#10003;</span> |                       | Removes PubSubConfig, adds defaults methods to Publisher/Subscriber interfaces and improves PubSubException | |
| 2017-08-16   | [**0.2.0**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.2.0)  | <span>&#10003;</span> |                       | PubSub interfaces and classes to implement custom communication between API and backend | |
| 2017-06-27   | [**0.1.2**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.1.2)  | <span>&#10003;</span> |                       | Changes to the BulletConfig interface previously used in Bullet Storm. Users now use BulletStormConfig instead but YAML config is the same | |
| 2017-06-27   | [**0.1.1**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.1.1)  | <span>&#10003;</span> |                       | First stable release containing the core of Bullet as a library including parsing, implementing queries, creating results, DataSketches etc | |

## Bullet Storm

The implementation of Bullet on Storm. Due to major API changes between Storm <= 0.10 and Storm 1.0, Bullet Storm used to [build two artifacts](backend/storm-setup.md#older-storm-versions). The ```artifactId``` changes from ```bullet-storm``` (for 1.0+) to ```bullet-storm-0.10```. All releases for both versions include migration and testing of the code on *both* platforms. Feature parity depends on what was new in Storm 1.0. For example, the Resource Aware Scheduler or RAS, is only present in Storm 1.0+. So, bullet-storm-0.10 removes certain CPU and memory related settings specific to RAS in its configuration. There are also minor changes to the Metrics API in Storm. In terms of Bullet itself, there should be no differences.

!!! note "Storm DRPC PubSub "

    The DRPC PubSub is part of this artifact and is fully released and available for use starting with versions 0.6.2 and above. It is only meant to be used if you're using Storm as your Backend.

!!! note "Storm 0.10"

    We will no longer support Storm 0.10 since Storm 2.0 is now stable starting with Bullet on Storm 1.0.

|                               |                 |
| ----------------------------- | --------------- |
| **Storm-1.0+ Repository**     | [https://github.com/bullet-db/bullet-storm](https://github.com/bullet-db/bullet-storm) |
| **Storm-0.10- Repository**    | [https://github.com/bullet-db/bullet-storm/tree/storm-0.10](https://github.com/bullet-db/bullet-storm/tree/storm-0.10) |
| **Issues**                    | [https://github.com/bullet-db/bullet-storm/issues](https://github.com/bullet-db/bullet-storm/issues) |
| **Last Tag**                  | [![Latest tag](https://img.shields.io/github/release/bullet-db/bullet-storm/all.svg)](https://github.com/bullet-db/bullet-storm/tags) |
| **Latest Artifact**           | [![Latest Artifact](https://maven-badges.herokuapp.com/maven-central/com.yahoo.bullet/bullet-storm/badge.svg)](https://maven-badges.herokuapp.com/maven-central/com.yahoo.bullet/bullet-storm) |
| **Package Manager Setup**     | [Maven Central](https://search.maven.org/artifact/com.yahoo.bullet/bullet-storm/${bullet.storm.version}/jar) |

### Releases

|    Date      |                            Storm 1.0+                                                  |                                 Storm 0.10                                                  |        JCenter        |      Maven Central    | Highlights | APIDocs |
| ------------ | -------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- | :-------------------: | :-------------------: | ---------- | ------- |
| 2021-09-01   | [**1.3.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-1.3.0) | -                                                                                           |                       | <span>&#10003;</span> | Bullet Core 1.5.0 and DSL 1.2.0 | [JavaDocs](apidocs/bullet-storm/1.3.0/index.html) |
| 2021-08-03   | [**1.2.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-1.2.1) | -                                                                                           |                       | <span>&#10003;</span> | Bullet Core 1.4.4 and DSL 1.1.8 | [JavaDocs](apidocs/bullet-storm/1.2.1/index.html) |
| 2021-07-07   | [**1.2.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-1.2.0) | -                                                                                           |                       | <span>&#10003;</span> | PubSubMessageSerDe. Bolts emit PubSubMessage. Bullet Core 1.4.2 and DSL 1.1.7 | [JavaDocs](apidocs/bullet-storm/1.2.0/index.html) |
| 2021-05-13   | [**1.1.4**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-1.1.4) | -                                                                                           |                       | <span>&#10003;</span> | Bullet Core 1.3.1 and DSL 1.1.6 | [JavaDocs](apidocs/bullet-storm/1.1.4/index.html) |
| 2021-04-27   | [**1.1.3**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-1.1.3) | -                                                                                           |                       | <span>&#10003;</span> | First release using Screwdriver | [JavaDocs](apidocs/bullet-storm/1.1.3/index.html) |
| 2021-04-23   | [**1.1.2**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-1.1.2) | -                                                                                           |                       | <span>&#10003;</span> | Bullet Core 1.2.2. First release on Maven Central | [JavaDocs](apidocs/bullet-storm/1.1.2/index.html) |
| 2021-03-25   | [**1.1.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-1.1.1) | -                                                                                           | <span>&#10003;</span> |                       | Bullet Core 1.2.1 | [JavaDocs](apidocs/bullet-storm/1.1.1/index.html) |
| 2021-03-19   | [**1.1.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-1.1.0) | -                                                                                           | <span>&#10003;</span> |                       | SpoutConnector | [JavaDocs](apidocs/bullet-storm/1.1.0/index.html) |
| 2021-03-01   | [**1.0.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-1.0.1) | -                                                                                           | <span>&#10003;</span> |                       | Extra submit API with Storm Config | [JavaDocs](apidocs/bullet-storm/1.0.1/index.html) |
| 2021-01-12   | [**1.0.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-1.0.0) | -                                                                                           | <span>&#10003;</span> |                       | Bullet Core 1.1, Replay, Storage | [JavaDocs](apidocs/bullet-storm/1.0.0/index.html) |
| 2019-02-07   | [**0.9.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.9.1) | [**0.9.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.9.1) | <span>&#10003;</span> |                       | Bullet DSL 0.1.2 and packaging fixes | [JavaDocs](apidocs/bullet-storm/0.9.1/index.html) |
| 2019-02-07   | [**0.9.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.9.0) | [**0.9.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.9.0) | <span>&#10003;</span> |                       | Bullet DSL support! | [JavaDocs](apidocs/bullet-storm/0.9.0/index.html) |
| 2018-11-26   | [**0.8.5**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.8.5) | [**0.8.5**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.8.5) | <span>&#10003;</span> |                       | Extended field notation and updates bullet-core to 0.6.4| [JavaDocs](apidocs/bullet-storm/0.8.5/index.html) |
| 2018-11-20   | [**0.8.4**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.8.4) | [**0.8.4**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.8.4) | <span>&#10003;</span> |                       | Partitioning and updates bullet-core to 0.6.2 | [JavaDocs](apidocs/bullet-storm/0.8.4/index.html) |
| 2018-06-18   | [**0.8.3**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.8.3) | [**0.8.3**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.8.3) | <span>&#10003;</span> |                       | Using new bullet-record and bullet-core supporting Integer and Float data types | [JavaDocs](apidocs/bullet-storm/0.8.3/index.html) |
| 2018-04-12   | [**0.8.2**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.8.2) | [**0.8.2**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.8.2) | <span>&#10003;</span> |                       | Delaying query start in Join bolt | |
| 2018-04-04   | [**0.8.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.8.1) | [**0.8.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.8.1) | <span>&#10003;</span> |                       | Fixed bug in Joinbolt | |
| 2018-03-30   | [**0.8.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.8.0) | [**0.8.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.8.0) | <span>&#10003;</span> |                       | Supports windowing / incremental updates | |
| 2017-11-07   | [**0.7.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.7.0) | [**0.7.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.7.0) | <span>&#10003;</span> |                       | Merge Query and Metadata Streams | |
| 2017-10-24   | [**0.6.2**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.6.2) | [**0.6.2**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.6.2) | <span>&#10003;</span> |                       | Adds a fat jar for using the DRPC PubSub in the Web Service | |
| 2017-10-18   | [**0.6.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.6.1) | [**0.6.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.6.1) | <span>&#10003;</span> |                       | DRPC PubSub | |
| 2017-08-30   | [**0.6.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.6.0) | [**0.6.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.6.0) | <span>&#10003;</span> |                       | New PubSub architecture, removes DRPC components and settings | |
| 2017-06-27   | [**0.5.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.5.0) | [**0.5.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.5.0) | <span>&#10003;</span> |                       | Pulled out Bullet Core. BulletConfig to BulletStormConfig | |
| 2017-06-09   | [**0.4.3**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.4.3) | [**0.4.3**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.4.3) | <span>&#10003;</span> |                       | Adding rounding for DISTRIBUTION. Latency metric | |
| 2017-04-28   | [**0.4.2**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.4.2) | [**0.4.2**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.4.2) | <span>&#10003;</span> |                       | Strict JSON output and fix for no data distributions | |
| 2017-04-26   | [**0.4.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.4.1) | [**0.4.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.4.1) | <span>&#10003;</span> |                       | Result Metadata Concept name mismatch fix | |
| 2017-04-21   | [**0.4.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.4.0) | [**0.4.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.4.0) | <span>&#10003;</span> |                       | DISTRIBUTION and TOP K release. Configuration renames. | |
| 2017-03-13   | [**0.3.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.3.1) | [**0.3.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.3.1) | <span>&#10003;</span> |                       | Extra records accepted after query expiry bug fix | |
| 2017-02-27   | [**0.3.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.3.0) | [**0.3.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.3.0) | <span>&#10003;</span> |                       | Metrics interface, config namespace, NPE bug fix | |
| 2017-02-15   | [**0.2.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.2.1) | [**0.2.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.2.1) | <span>&#10003;</span> |                       | Acking support, Max size and other bug fixes | |
| 2017-01-26   | [**0.2.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.2.0) | [**0.2.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.2.0) | <span>&#10003;</span> |                       | GROUP (DISTINCT, SUM, COUNT, MIN, MAX, AVG) | |
| 2017-01-09   | [**0.1.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.1.0) | [**0.1.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.1.0) | <span>&#10003;</span> |                       | COUNT DISTINCT and micro-batching | |

## Bullet Spark

The implementation of Bullet on Spark Streaming.

|                           |                 |
| ------------------------- | --------------- |
| **Repository**            | [https://github.com/bullet-db/bullet-spark](https://github.com/bullet-db/bullet-spark) |
| **Issues**                | [https://github.com/bullet-db/bullet-spark/issues](https://github.com/bullet-db/bullet-spark/issues) |
| **Last Tag**              | [![Latest tag](https://img.shields.io/github/release/bullet-db/bullet-spark/all.svg)](https://github.com/bullet-db/bullet-spark/tags) |
| **Latest Artifact**       | [![Latest Artifact](https://maven-badges.herokuapp.com/maven-central/com.yahoo.bullet/bullet-spark/badge.svg)](https://maven-badges.herokuapp.com/maven-central/com.yahoo.bullet/bullet-spark) |
| **Package Manager Setup** | [Maven Central](https://search.maven.org/artifact/com.yahoo.bullet/bullet-spark/${bullet.spark.version}/jar) |

### Releases

|    Date      |                                      Release                                            |        JCenter        |      Maven Central    | Highlights | APIDocs |
| ------------ | --------------------------------------------------------------------------------------- | :-------------------: | :-------------------: | ---------- | ------- |
| 2021-09-01   | [**1.2.0**](https://github.com/bullet-db/bullet-spark/releases/tag/bullet-spark-1.2.0)  |                       | <span>&#10003;</span> | Bullet Core 1.5.0 and DSL 1.2.0 | [SparkDocs](apidocs/bullet-spark/1.2.0/index.html) |
| 2021-08-03   | [**1.1.1**](https://github.com/bullet-db/bullet-spark/releases/tag/bullet-spark-1.1.1)  |                       | <span>&#10003;</span> | Bullet Core 1.4.4 and DSL 1.1.8 | [SparkDocs](apidocs/bullet-spark/1.1.1/index.html) |
| 2021-07-07   | [**1.1.0**](https://github.com/bullet-db/bullet-spark/releases/tag/bullet-spark-1.1.0)  |                       | <span>&#10003;</span> | Bullet Core 1.4.2 and DSL 1.1.7. Supports PubSubMessageSerDe | [SparkDocs](apidocs/bullet-spark/1.1.0/index.html) |
| 2021-05-14   | [**1.0.4**](https://github.com/bullet-db/bullet-spark/releases/tag/bullet-spark-1.0.4)  |                       | <span>&#10003;</span> | Bullet Core 1.3.1 and DSL 1.1.6. Avro BulletRecords serialize properly with Kryo enabled | [SparkDocs](apidocs/bullet-spark/1.0.4/index.html) |
| 2021-04-27   | [**1.0.3**](https://github.com/bullet-db/bullet-spark/releases/tag/bullet-spark-1.0.3)  |                       | <span>&#10003;</span> | First release using Screwdriver | [SparkDocs](apidocs/bullet-spark/1.0.3/index.html) |
| 2021-04-23   | [**1.0.2**](https://github.com/bullet-db/bullet-spark/releases/tag/bullet-spark-1.0.2)  |                       | <span>&#10003;</span> | First release on Maven Central. Bullet Core 1.2.2 | [SparkDocs](apidocs/bullet-spark/1.0.2/index.html) |
| 2021-03-25   | [**1.0.1**](https://github.com/bullet-db/bullet-spark/releases/tag/bullet-spark-1.0.1)  | <span>&#10003;</span> |                       | Bullet Core 1.2.1 | [SparkDocs](apidocs/bullet-spark/1.0.1/index.html) |
| 2021-02-12   | [**1.0.0**](https://github.com/bullet-db/bullet-spark/releases/tag/bullet-spark-1.0.0)  | <span>&#10003;</span> |                       | Bullet Core 1.2.0, DSL | [SparkDocs](apidocs/bullet-spark/1.0.0/index.html) |
| 2019-02-07   | [**0.2.2**](https://github.com/bullet-db/bullet-spark/releases/tag/bullet-spark-0.2.2)  | <span>&#10003;</span> |                       | Fixes a NPE in JoinStreaming for very short queries | [SparkDocs](apidocs/bullet-spark/0.2.2/index.html) |
| 2018-11-26   | [**0.2.1**](https://github.com/bullet-db/bullet-spark/releases/tag/bullet-spark-0.2.1)  | <span>&#10003;</span> |                       | Uses bullet-core 0.6.4 and supports extended field notation in queries | [SparkDocs](apidocs/bullet-spark/0.2.1/index.html) |
| 2018-11-16   | [**0.2.0**](https://github.com/bullet-db/bullet-spark/releases/tag/bullet-spark-0.2.0)  | <span>&#10003;</span> |                       | Uses bullet-core 0.6.1 and adds partitioning support | [SparkDocs](apidocs/bullet-spark/0.2.0/index.html) |
| 2018-06-18   | [**0.1.2**](https://github.com/bullet-db/bullet-spark/releases/tag/bullet-spark-0.1.2)  | <span>&#10003;</span> |                       | Uses SimpleBulletRecord to avoid some Spark serialization issues with Avro | [SparkDocs](apidocs/bullet-spark/0.1.2/index.html) |
| 2018-06-08   | [**0.1.1**](https://github.com/bullet-db/bullet-spark/releases/tag/bullet-spark-0.1.1)  | <span>&#10003;</span> |                       | Adds a command flag to pass custom setting file | |
| 2018-05-25   | [**0.1.0**](https://github.com/bullet-db/bullet-spark/releases/tag/bullet-spark-0.1.0)  | <span>&#10003;</span> |                       | The first release | |

## Bullet Web Service

The Web Service implementation that can serve a static schema from a file and talk to the backend using the PubSub.

!!! note "WAR to JAR"

    Starting with 0.1.1 and above, this artifact no longer produces a WAR file that is meant to be run in a servlet container and instead switches to an executable Java application using Spring Boot.

|                           |                 |
| ------------------------- | --------------- |
| **Repository**            | [https://github.com/bullet-db/bullet-service](https://github.com/bullet-db/bullet-service) |
| **Issues**                | [https://github.com/bullet-db/bullet-service/issues](https://github.com/bullet-db/bullet-service/issues) |
| **Last Tag**              | [![Latest tag](https://img.shields.io/github/release/bullet-db/bullet-service/all.svg)](https://github.com/bullet-db/bullet-service/tags) |
| **Latest Artifact**       | [![Latest Artifact](https://maven-badges.herokuapp.com/maven-central/com.yahoo.bullet/bullet-service/badge.svg)](https://maven-badges.herokuapp.com/maven-central/com.yahoo.bullet/bullet-service) |
| **Package Manager Setup** | [Maven Central](https://search.maven.org/artifact/com.yahoo.bullet/bullet-service/${bullet.service.version}/jar) |

### Releases

|    Date      |                                      Release                                               |        JCenter        |      Maven Central    | Highlights | APIDocs |
| ------------ | ------------------------------------------------------------------------------------------ | :-------------------: | :-------------------: | ---------- | ------- |
| 2021-09-01   | [**1.4.0**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-1.4.0) |                       | <span>&#10003;</span> | Bullet Core 1.5.0 and BQL 1.3.0 | [JavaDocs](apidocs/bullet-service/1.4.0/index.html) |
| 2021-08-03   | [**1.3.2**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-1.3.2) |                       | <span>&#10003;</span> | Bullet Core 1.4.4 and BQL 1.2.5 | [JavaDocs](apidocs/bullet-service/1.3.2/index.html) |
| 2021-07-27   | [**1.3.1**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-1.3.1) |                       | <span>&#10003;</span> | Fixes metrics reporting when storage is not configured | [JavaDocs](apidocs/bullet-service/1.3.1/index.html) |
| 2021-07-26   | [**1.3.0**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-1.3.0) |                       | <span>&#10003;</span> | Adds a bunch of new metrics that are reported for queries (async and sync) | [JavaDocs](apidocs/bullet-service/1.3.0/index.html) |
| 2021-06-30   | [**1.2.3**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-1.2.3) |                       | <span>&#10003;</span> | Bullet Core 1.4.2 and BQL 1.2.4 | [JavaDocs](apidocs/bullet-service/1.2.3/index.html) |
| 2021-06-28   | [**1.2.2**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-1.2.2) |                       | <span>&#10003;</span> | Bug fix for QueryService#get not using the PubSubMessageSerDe | [JavaDocs](apidocs/bullet-service/1.2.2/index.html) |
| 2021-06-25   | [**1.2.1**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-1.2.1) |                       | <span>&#10003;</span> | Uses ByteArrayPubSubMessageSerDe by default. Bullet Core 1.4.1 | [JavaDocs](apidocs/bullet-service/1.2.1/index.html) |
| 2021-06-24   | [**1.2.0**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-1.2.0) |                       | <span>&#10003;</span> | Supports PubSubMessageSerDe. Bullet Core 1.4.0 and BQL 1.2.2 | [JavaDocs](apidocs/bullet-service/1.2.0/index.html) |
| 2021-06-17   | [**1.1.0**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-1.1.0) |                       | <span>&#10003;</span> | Adds a get interface to QueryService to retrieve stored queries | [JavaDocs](apidocs/bullet-service/1.1.0/index.html) |
| 2021-05-13   | [**1.0.4**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-1.0.4) |                       | <span>&#10003;</span> | Bullet Core 1.3.1 and BQL 1.2.0 | [JavaDocs](apidocs/bullet-service/1.0.4/index.html) |
| 2021-04-27   | [**1.0.3**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-1.0.3) |                       | <span>&#10003;</span> | First release using Screwdriver | [JavaDocs](apidocs/bullet-service/1.0.3/index.html) |
| 2021-04-23   | [**1.0.2**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-1.0.2) |                       | <span>&#10003;</span> | First release on Maven Central. Bullet Core 1.2.2 | [JavaDocs](apidocs/bullet-service/1.0.2/index.html) |
| 2021-03-25   | [**1.0.1**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-1.0.1) | <span>&#10003;</span> |                       | Bullet Core 1.2.1 | [JavaDocs](apidocs/bullet-service/1.0.1/index.html) |
| 2021-01-12   | [**1.0.0**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-1.0.0) | <span>&#10003;</span> |                       | Async queries, Storage, Metrics, BQL only 1.0, Bullet Core 1.0 | [JavaDocs](apidocs/bullet-service/1.0.0/index.html) |
| 2019-03-07   | [**0.5.0**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.5.0) | <span>&#10003;</span> |                       | QueryManager API updates | [JavaDocs](apidocs/bullet-service/0.5.0/index.html) |
| 2018-11-28   | [**0.4.3**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.4.3) | <span>&#10003;</span> |                       | Updates bullet-bql to 0.2.1 | [JavaDocs](apidocs/bullet-service/0.4.3/index.html) |
| 2018-11-26   | [**0.4.2**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.4.2) | <span>&#10003;</span> |                       | BQL to JSON endpoint, dead backend reaper, new types in Schema, bullet-core 0.6.4 | [JavaDocs](apidocs/bullet-service/0.4.2/index.html) |
| 2018-09-06   | [**0.4.1**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.4.1) | <span>&#10003;</span> |                       | Max Queries limit and bullet-bql 0.1.2 | [JavaDocs](apidocs/bullet-service/0.4.1/index.html) |
| 2018-07-17   | [**0.4.0**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.4.0) | <span>&#10003;</span> |                       | Enhanced Web Service to support BQL queries | [JavaDocs](apidocs/bullet-service/0.4.0/index.html) |
| 2018-06-25   | [**0.3.0**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.3.0) | <span>&#10003;</span> |                       | Upgrades to Netty-less Bullet Core for the RESTPubsub | |
| 2018-06-14   | [**0.2.2**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.2.2) | <span>&#10003;</span> |                       | Adding settings to configure Websocket | |
| 2018-04-02   | [**0.2.1**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.2.1) | <span>&#10003;</span> |                       | Moved and renamed settings | |
| 2018-03-30   | [**0.2.0**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.2.0) | <span>&#10003;</span> |                       | Supporting windowing / incremental updates | |
| 2017-10-19   | [**0.1.1**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.1.1) | <span>&#10003;</span> |                       | New PubSub architecture. Switching to Spring Boot and executable JAR instead of WAR | |
| 2016-12-16   | [**0.0.1**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.0.1) | <span>&#10003;</span> |                       | The first release with support for DRPC and the file-based schema | |

!!! note "Want to directly download jars?"

    Head over to the Maven Central download page to [directly download all Bullet Storm, Core, Service, Record artifacts](https://repo1.maven.org/maven2/com/yahoo/bullet/).

## Bullet UI

The Bullet UI that lets you build, run, save and visualize results from Bullet.

|                     |                 |
| ------------------- | --------------- |
| **Repository**      | [https://github.com/bullet-db/bullet-ui](https://github.com/bullet-db/bullet-ui) |
| **Issues**          | [https://github.com/bullet-db/bullet-ui/issues](https://github.com/bullet-db/bullet-ui/issues) |
| **Last Tag**        | [![GitHub release](https://img.shields.io/github/tag/bullet-db/bullet-ui.svg)](https://github.com/bullet-db/bullet-ui/tags) |
| **Latest Artifact** | [![GitHub release](https://img.shields.io/github/release/bullet-db/bullet-ui.svg)](https://github.com/bullet-db/bullet-ui/releases/latest) |

### Releases

|    Date      |                                      Release                            | Highlights |
| ------------ | ----------------------------------------------------------------------- | ---------- |
| 2021-05-18   | [**1.1.0**](https://github.com/bullet-db/bullet-ui/releases/tag/v1.1.0) | Supports BQL upto Bullet BQL 1.2.0 (EXPLODE, LATERAL VIEW etc). Bug fixes for schema table, query builder subfield and bql auto-complete |
| 2021-03-09   | [**1.0.2**](https://github.com/bullet-db/bullet-ui/releases/tag/v1.0.2) | Link update for the BQL API |
| 2021-02-18   | [**1.0.1**](https://github.com/bullet-db/bullet-ui/releases/tag/v1.0.1) | Stomp Websocket disconnect on query end |
| 2021-01-12   | [**1.0.0**](https://github.com/bullet-db/bullet-ui/releases/tag/v1.0.0) | Ember 3 Octane, BQL support, new filter operators |
| 2019-03-18   | [**0.6.2**](https://github.com/bullet-db/bullet-ui/releases/tag/v0.6.2) | Logo update |
| 2018-10-05   | [**0.6.1**](https://github.com/bullet-db/bullet-ui/releases/tag/v0.6.1) | Timeseries Graphing, Bar, Pie Charts and FontAwesome |
| 2018-07-20   | [**0.6.0**](https://github.com/bullet-db/bullet-ui/releases/tag/v0.6.0) | Supports adding a full default starting query |
| 2018-06-18   | [**0.5.0**](https://github.com/bullet-db/bullet-ui/releases/tag/v0.5.0) | Supports windowing, uses IndexedDB and Ember 3! |
| 2017-08-22   | [**0.4.0**](https://github.com/bullet-db/bullet-ui/releases/tag/v0.4.0) | Query sharing, collapsible Raw view, and unsaved/error indicators. Settings rename and other bug fixes|
| 2017-05-22   | [**0.3.2**](https://github.com/bullet-db/bullet-ui/releases/tag/v0.3.2) | Exporting to TSV in Pivot table. Fixes unselectability bug in Raw view |
| 2017-05-15   | [**0.3.1**](https://github.com/bullet-db/bullet-ui/releases/tag/v0.3.1) | Adds styles to the Pivot table. Fixes some minor UI interactions |
| 2017-05-10   | [**0.3.0**](https://github.com/bullet-db/bullet-ui/releases/tag/v0.3.0) | Adds Charting and Pivoting support. Migrations enhanced. Support for overriding nested default settings |
| 2017-05-03   | [**0.2.2**](https://github.com/bullet-db/bullet-ui/releases/tag/v0.2.2) | Fixes maxlength of the input for points |
| 2017-05-02   | [**0.2.1**](https://github.com/bullet-db/bullet-ui/releases/tag/v0.2.1) | Fixes a bug with a dependency that broke sorting the Filters |
| 2017-05-01   | [**0.2.0**](https://github.com/bullet-db/bullet-ui/releases/tag/v0.2.0) | Release for Top K and Distribution. Supports Bullet Storm 0.4.2+ |
| 2017-02-21   | [**0.1.0**](https://github.com/bullet-db/bullet-ui/releases/tag/v0.1.0) | The first release with support for all features included in Bullet Storm 0.2.1+ |

## Bullet Record

The AVRO and other containers that you need to convert your data into to be consumed by Bullet. Also manages the typing in Bullet.

|                           |                 |
| ------------------------- | --------------- |
| **Repository**            | [https://github.com/bullet-db/bullet-record](https://github.com/bullet-db/bullet-record) |
| **Issues**                | [https://github.com/bullet-db/bullet-record/issues](https://github.com/bullet-db/bullet-record/issues) |
| **Last Tag**              | [![Latest tag](https://img.shields.io/github/release/bullet-db/bullet-record/all.svg)](https://github.com/bullet-db/bullet-record/tags) |
| **Latest Artifact**       | [![Latest Artifact](https://maven-badges.herokuapp.com/maven-central/com.yahoo.bullet/bullet-record/badge.svg)](https://maven-badges.herokuapp.com/maven-central/com.yahoo.bullet/bullet-record) |
| **Package Manager Setup** | [Maven Central](https://search.maven.org/artifact/com.yahoo.bullet/bullet-record/${bullet.record.version}/jar) |

### Releases

|    Date      |                                  Release                                                 |        JCenter        |      Maven Central    | Highlights | APIDocs |
| ------------ | ---------------------------------------------------------------------------------------- | :-------------------: | :-------------------: | ---------- | ------- |
| 2021-07-30   | [**1.2.0**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-1.2.0) |                       | <span>&#10003;</span> | UNKNOWN type guessing and support for UNKNOWN container types as first class. Allows much deeper types than what is supported | [JavaDocs](apidocs/bullet-record/1.2.0/index.html) |
| 2021-06-29   | [**1.1.4**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-1.1.4) |                       | <span>&#10003;</span> | LazyBulletAvro does not cause a SerDe cycle when copy constructing | [JavaDocs](apidocs/bullet-record/1.1.4/index.html) |
| 2021-05-13   | [**1.1.3**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-1.1.3) |                       | <span>&#10003;</span> | Exposes LazyBulletAvro to plug in other Avros | [JavaDocs](apidocs/bullet-record/1.1.3/index.html) |
| 2021-04-27   | [**1.1.2**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-1.1.2) |                       | <span>&#10003;</span> | First release using Screwdriver | [JavaDocs](apidocs/bullet-record/1.1.2/index.html) |
| 2021-04-22   | [**1.1.1**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-1.1.1) |                       | <span>&#10003;</span> | First release on Maven Central | [JavaDocs](apidocs/bullet-record/1.1.1/index.html) |
| 2020-10-30   | [**1.1.0**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-1.1.0) | <span>&#10003;</span> |                       | Ternary logic | [JavaDocs](apidocs/bullet-record/1.1.0/index.html) |
| 2020-06-04   | [**1.0.0**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-1.0.0) | <span>&#10003;</span> |                       | Type System, Typed records, Schemas, extended Types | [JavaDocs](apidocs/bullet-record/1.0.0/index.html) |
| 2018-11-21   | [**0.3.0**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-0.3.0) | <span>&#10003;</span> |                       | More setters in BulletRecord including a forceSet | [JavaDocs](apidocs/bullet-record/0.3.0/index.html) |
| 2018-10-30   | [**0.2.2**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-0.2.2) | <span>&#10003;</span> |                       | Extract from Lists and Map of Maps | [JavaDocs](apidocs/bullet-record/0.2.2/index.html) |
| 2018-08-14   | [**0.2.1**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-0.2.1) | <span>&#10003;</span> |                       | Supports List of Primitive types | [JavaDocs](apidocs/bullet-record/0.2.1/index.html) |
| 2018-06-14   | [**0.2.0**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-0.2.0) | <span>&#10003;</span> |                       | Makes BulletRecord pluggable, adds simple record and Avro record implementations | [JavaDocs](apidocs/bullet-record/0.2.0/index.html) |
| 2017-05-19   | [**0.1.2**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-0.1.2) | <span>&#10003;</span> |                       | Reduces the memory footprint needed to serialize itself by a factor of 128 for small records | |
| 2017-04-17   | [**0.1.1**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-0.1.1) | <span>&#10003;</span> |                       | Helper methods to remove, rename, check presence and count fields in the Record | |
| 2017-02-09   | [**0.1.0**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-0.1.0) | <span>&#10003;</span> |                       | Map constructor | |

## Bullet DSL

A DSL to plug data sources into the Bullet Backend and Web Service.

|                           |                 |
| ------------------------- | --------------- |
| **Repository**            | [https://github.com/bullet-db/bullet-dsl](https://github.com/bullet-db/bullet-dsl) |
| **Issues**                | [https://github.com/bullet-db/bullet-dsl/issues](https://github.com/bullet-db/bullet-dsl/issues) |
| **Last Tag**              | [![Latest tag](https://img.shields.io/github/release/bullet-db/bullet-dsl/all.svg)](https://github.com/bullet-db/bullet-dsl/tags) |
| **Latest Artifact**       | [![Latest Artifact](https://maven-badges.herokuapp.com/maven-central/com.yahoo.bullet/bullet-dsl/badge.svg)](https://maven-badges.herokuapp.com/maven-central/com.yahoo.bullet/bullet-dsl) |
| **Package Manager Setup** | [Maven Central](https://search.maven.org/artifact/com.yahoo.bullet/bullet-dsl/${bullet.dsl.version}/jar) |

### Releases

|    Date      |                                  Release                                                 |        JCenter        |      Maven Central    | Highlights | APIDocs |
| ------------ | ---------------------------------------------------------------------------------------- | :-------------------: | :-------------------: | ---------- | ------- |
| 2021-09-01   | [**1.2.0**](https://github.com/bullet-db/bullet-dsl/releases/tag/bullet-dsl-1.2.0)       |                       | <span>&#10003;</span> | Bullet Core 1.5.0. AvroRecordConverter exposes hooks to modify its behavior for various conversions | [JavaDocs](apidocs/bullet-dsl/1.2.0/index.html) |
| 2021-08-02   | [**1.1.8**](https://github.com/bullet-db/bullet-dsl/releases/tag/bullet-dsl-1.1.8)       |                       | <span>&#10003;</span> | Bullet Core 1.4.4. AvroRecordConverter supports Avro Record types | [JavaDocs](apidocs/bullet-dsl/1.1.8/index.html) |
| 2021-06-30   | [**1.1.7**](https://github.com/bullet-db/bullet-dsl/releases/tag/bullet-dsl-1.1.7)       |                       | <span>&#10003;</span> | Bullet Core 1.4.2 | [JavaDocs](apidocs/bullet-dsl/1.1.7/index.html) |
| 2021-05-13   | [**1.1.6**](https://github.com/bullet-db/bullet-dsl/releases/tag/bullet-dsl-1.1.6)       |                       | <span>&#10003;</span> | Bullet Core 1.3.1 | [JavaDocs](apidocs/bullet-dsl/1.1.6/index.html) |
| 2021-04-27   | [**1.1.5**](https://github.com/bullet-db/bullet-dsl/releases/tag/bullet-dsl-1.1.5)       |                       | <span>&#10003;</span> | First release using Screwdriver | [JavaDocs](apidocs/bullet-dsl/1.1.5/index.html) |
| 2021-04-22   | [**1.1.4**](https://github.com/bullet-db/bullet-dsl/releases/tag/bullet-dsl-1.1.4)       |                       |                       | First release on Maven Central. Bullet Core 1.2.2 and uses Lang3 Pair instead of JavaFX Pair | [JavaDocs](apidocs/bullet-dsl/1.1.4/index.html) |
| 2021-03-25   | [**1.1.3**](https://github.com/bullet-db/bullet-dsl/releases/tag/bullet-dsl-1.1.3)       | <span>&#10003;</span> |                       | Schema defaults changed from "" to null since Yaml library changed | [JavaDocs](apidocs/bullet-dsl/1.1.3/index.html) |
| 2021-03-25   | [**1.1.2**](https://github.com/bullet-db/bullet-dsl/releases/tag/bullet-dsl-1.1.2)       | <span>&#10003;</span> |                       | Bullet Core 1.2.1 and Kafka Clients 2.6.0 | [JavaDocs](apidocs/bullet-dsl/1.1.2/index.html) |
| 2021-03-18   | [**1.1.1**](https://github.com/bullet-db/bullet-dsl/releases/tag/bullet-dsl-1.1.0)       | <span>&#10003;</span> |                       | AvroBulletRecordConverter fixing String types | [JavaDocs](apidocs/bullet-dsl/1.1.1/index.html) |
| 2021-02-17   | [**1.1.0**](https://github.com/bullet-db/bullet-dsl/releases/tag/bullet-dsl-1.1.0)       | <span>&#10003;</span> |                       | JSONBulletRecordConverter | [JavaDocs](apidocs/bullet-dsl/1.1.0/index.html) |
| 2021-02-11   | [**1.0.1**](https://github.com/bullet-db/bullet-dsl/releases/tag/bullet-dsl-1.0.1)       | <span>&#10003;</span> |                       | Bullet Core 1.2, Unsets default connector/converter | [JavaDocs](apidocs/bullet-dsl/1.0.1/index.html) |
| 2020-10-30   | [**1.0.0**](https://github.com/bullet-db/bullet-dsl/releases/tag/bullet-dsl-1.0.0)       | <span>&#10003;</span> |                       | Bullet Core 1.1, Types to match Bullet Record 1.1 | [JavaDocs](apidocs/bullet-dsl/1.0.0/index.html) |
| 2019-02-07   | [**0.1.1**](https://github.com/bullet-db/bullet-dsl/releases/tag/bullet-dsl-0.1.1)       | <span>&#10003;</span> |                       | Interface consolidation, IdentityDeserializer | [JavaDocs](apidocs/bullet-dsl/0.1.1/index.html) |
| 2019-02-05   | [**0.1.0**](https://github.com/bullet-db/bullet-dsl/releases/tag/bullet-dsl-0.1.0)       | <span>&#10003;</span> |                       | Bullet DSL, Fat jar, Interface refactors | [JavaDocs](apidocs/bullet-dsl/0.1.0/index.html) |
| 2019-01-08   | [**0.0.1**](https://github.com/bullet-db/bullet-dsl/releases/tag/bullet-dsl-0.0.1)       | <span>&#10003;</span> |                       | First release | [JavaDocs](apidocs/bullet-dsl/0.0.1/index.html) |

## Bullet Kafka

A PubSub implementation using Kafka as the backing PubSub. Can be used with any Bullet Backend.

|                           |                 |
| ------------------------- | --------------- |
| **Repository**            | [https://github.com/bullet-db/bullet-kafka](https://github.com/bullet-db/bullet-kafka) |
| **Issues**                | [https://github.com/bullet-db/bullet-kafka/issues](https://github.com/bullet-db/bullet-kafka/issues) |
| **Last Tag**              | [![Latest tag](https://img.shields.io/github/release/bullet-db/bullet-kafka/all.svg)](https://github.com/bullet-db/bullet-kafka/tags) |
| **Latest Artifact**       | [![Latest Artifact](https://maven-badges.herokuapp.com/maven-central/com.yahoo.bullet/bullet-kafka/badge.svg)](https://maven-badges.herokuapp.com/maven-central/com.yahoo.bullet/bullet-kafka) |
| **Package Manager Setup** | [Maven Central](https://search.maven.org/artifact/com.yahoo.bullet/bullet-kafka/${bullet.kafka.version}/jar) |

### Releases

|    Date      |                                  Release                                               |        JCenter        |      Maven Central    | Highlights | APIDocs |
| ------------ | -------------------------------------------------------------------------------------- | :-------------------: | :-------------------: | ---------- | ------- |
| 2021-09-01   | [**1.3.0**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-1.3.0) |                       | <span>&#10003;</span> | Bullet Core 1.5.0 | [JavaDocs](apidocs/bullet-kafka/1.3.0/index.html) |
| 2021-08-02   | [**1.2.4**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-1.2.4) |                       | <span>&#10003;</span> | Bullet Core 1.4.4 | [JavaDocs](apidocs/bullet-kafka/1.2.4/index.html) |
| 2021-06-30   | [**1.2.3**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-1.2.3) |                       | <span>&#10003;</span> | Bullet Core 1.4.2 | [JavaDocs](apidocs/bullet-kafka/1.2.3/index.html) |
| 2021-05-13   | [**1.2.2**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-1.2.2) |                       | <span>&#10003;</span> | Bullet Core 1.3.1 | [JavaDocs](apidocs/bullet-kafka/1.2.2/index.html) |
| 2021-05-07   | [**1.2.1**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-1.2.1) |                       | <span>&#10003;</span> | Bug fix for response partitions not being honored if partition routing is disabled | [JavaDocs](apidocs/bullet-kafka/1.2.1/index.html) |
| 2021-05-07   | [**1.2.0**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-1.2.0) |                       | <span>&#10003;</span> | KafkaSubscriber now supports rate limiting. Optional disabling for partition routing | [JavaDocs](apidocs/bullet-kafka/1.2.0/index.html) |
| 2021-04-27   | [**1.1.3**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-1.1.3) |                       | <span>&#10003;</span> | First release using Screwdriver | [JavaDocs](apidocs/bullet-kafka/1.1.3/index.html) |
| 2021-04-22   | [**1.1.2**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-1.1.2) |                       | <span>&#10003;</span> | First release on Maven Central. Bullet Core 1.2.2 | [JavaDocs](apidocs/bullet-kafka/1.1.2/index.html) |
| 2021-04-05   | [**1.1.1**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-1.1.1) | <span>&#10003;</span> |                       | Bug fix for Kafka CertRefresher refresh interval configuration type mismatch | [JavaDocs](apidocs/bullet-kafka/1.1.1/index.html) |
| 2021-04-05   | [**1.1.0**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-1.1.0) | <span>&#10003;</span> |                       | Kafka CertRefresher implementation for auto refreshing SSL credentials | [JavaDocs](apidocs/bullet-kafka/1.1.0/index.html) |
| 2021-03-25   | [**1.0.2**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-1.0.2) | <span>&#10003;</span> |                       | Bullet Core 1.2.1 and Kafka Clients 2.6.0 | [JavaDocs](apidocs/bullet-kafka/1.0.2/index.html) |
| 2021-02-17   | [**1.0.1**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-1.0.1) | <span>&#10003;</span> |                       | Bullet Core 1.2 | [JavaDocs](apidocs/bullet-kafka/1.0.1/index.html) |
| 2020-10-30   | [**1.0.0**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-1.0.0) | <span>&#10003;</span> |                       | Bullet Core 1.1 | [JavaDocs](apidocs/bullet-kafka/1.0.0/index.html) |
| 2018-12-17   | [**0.3.3**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-0.3.3) | <span>&#10003;</span> |                       | Removes adding unnecessary properties to Producers/Consumers | [JavaDocs](apidocs/bullet-kafka/0.3.3/index.html) |
| 2018-11-26   | [**0.3.2**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-0.3.2) | <span>&#10003;</span> |                       | Uses bullet-core-0.6.4 | [JavaDocs](apidocs/bullet-kafka/0.3.2/index.html) |
| 2018-11-26   | [**0.3.1**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-0.3.1) | <span>&#10003;</span> |                       | Uses bullet-core-0.6.0 and adds Validator | [JavaDocs](apidocs/bullet-kafka/0.3.1/index.html) |
| 2018-02-27   | [**0.3.0**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-0.3.0) | <span>&#10003;</span> |                       | Uses bullet-core-0.3.0 - windows / incremental updates | [JavaDocs](apidocs/bullet-kafka/0.3.0/index.html) |
| 2017-10-19   | [**0.2.0**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-0.2.0) | <span>&#10003;</span> |                       | Refactors and re-releases. Pass-through settings to Kafka. Manual offset committing bug fix | |
| 2017-09-27   | [**0.1.2**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-0.1.2) | <span>&#10003;</span> |                       | Fixes a bug with config loading | |
| 2017-09-22   | [**0.1.1**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-0.1.1) | <span>&#10003;</span> |                       | First release using the PubSub interfaces | |

## Bullet Pulsar

A PubSub implementation using Pulsar as the backing PubSub. Can be used with any Bullet Backend.

|                           |                 |
| ------------------------- | --------------- |
| **Repository**            | [https://github.com/bullet-db/bullet-pulsar](https://github.com/bullet-db/bullet-pulsar) |
| **Issues**                | [https://github.com/bullet-db/bullet-pulsar/issues](https://github.com/bullet-db/bullet-pulsar/issues) |
| **Last Tag**              | [![Latest tag](https://img.shields.io/github/release/bullet-db/bullet-kafka/all.svg)](https://github.com/bullet-db/bullet-pulsar/tags) |
| **Latest Artifact**       | [![Latest Artifact](https://maven-badges.herokuapp.com/maven-central/com.yahoo.bullet/bullet-pulsar/badge.svg)](https://maven-badges.herokuapp.com/maven-central/com.yahoo.bullet/bullet-pulsar) |
| **Package Manager Setup** | [Maven Central](https://search.maven.org/artifact/com.yahoo.bullet/bullet-pulsar/${bullet.pulsar.version}/jar) |

### Releases

|    Date      |                                  Release                                                 |        JCenter        |      Maven Central    | Highlights | APIDocs |
| ------------ | ---------------------------------------------------------------------------------------- | :-------------------: | :-------------------: | ---------- | ------- |
| 2021-09-01   | [**1.1.0**](https://github.com/bullet-db/bullet-pulsar/releases/tag/bullet-pulsar-1.1.0) |                       | <span>&#10003;</span> | Bullet Core 1.5.0 | [JavaDocs](apidocs/bullet-pulsar/1.1.0/index.html) |
| 2021-08-02   | [**1.0.6**](https://github.com/bullet-db/bullet-pulsar/releases/tag/bullet-pulsar-1.0.6) |                       | <span>&#10003;</span> | Bullet Core 1.4.4 | [JavaDocs](apidocs/bullet-pulsar/1.0.6/index.html) |
| 2021-06-30   | [**1.0.5**](https://github.com/bullet-db/bullet-pulsar/releases/tag/bullet-pulsar-1.0.5) |                       | <span>&#10003;</span> | Bullet Core 1.4.2 | [JavaDocs](apidocs/bullet-pulsar/1.0.5/index.html) |
| 2021-05-13   | [**1.0.4**](https://github.com/bullet-db/bullet-pulsar/releases/tag/bullet-pulsar-1.0.4) |                       | <span>&#10003;</span> | Bullet Core 1.3.1 | [JavaDocs](apidocs/bullet-pulsar/1.0.4/index.html) |
| 2021-04-27   | [**1.0.3**](https://github.com/bullet-db/bullet-pulsar/releases/tag/bullet-pulsar-1.0.3) |                       | <span>&#10003;</span> | First release using Screwdriver | [JavaDocs](apidocs/bullet-pulsar/1.0.3/index.html) |
| 2021-04-22   | [**1.0.2**](https://github.com/bullet-db/bullet-pulsar/releases/tag/bullet-pulsar-1.0.2) |                       | <span>&#10003;</span> | First release on Maven Central. Bullet Core 1.2.2 | [JavaDocs](apidocs/bullet-pulsar/1.0.2/index.html) |
| 2021-03-25   | [**1.0.1**](https://github.com/bullet-db/bullet-pulsar/releases/tag/bullet-pulsar-1.0.1) | <span>&#10003;</span> |                       | Bullet Core 1.2.1 | [JavaDocs](apidocs/bullet-pulsar/1.0.1/index.html) |
| 2020-10-30   | [**1.0.0**](https://github.com/bullet-db/bullet-pulsar/releases/tag/bullet-pulsar-1.0.0) | <span>&#10003;</span> |                       | Bullet Core 1.1.0 | [JavaDocs](apidocs/bullet-pulsar/1.0.0/index.html) |
| 2018-12-10   | [**0.1.0**](https://github.com/bullet-db/bullet-pulsar/releases/tag/bullet-pulsar-0.1.0) | <span>&#10003;</span> |                       | First release using the PubSub interfaces | [JavaDocs](apidocs/bullet-pulsar/0.1.0/index.html) |

## Bullet BQL

A library facilitating the conversion from Bullet BQL queries to Bullet queries. This is the interface to the API.

|                           |                 |
| ------------------------- | --------------- |
| **Repository**            | [https://github.com/bullet-db/bullet-bql](https://github.com/bullet-db/bullet-bql) |
| **Issues**                | [https://github.com/bullet-db/bullet-bql/issues](https://github.com/bullet-db/bullet-bql/issues) |
| **Last Tag**              | [![Latest tag](https://img.shields.io/github/release/bullet-db/bullet-bql/all.svg)](https://github.com/bullet-db/bullet-bql/tags) |
| **Latest Artifact**       | [![Latest Artifact](https://maven-badges.herokuapp.com/maven-central/com.yahoo.bullet/bullet-bql/badge.svg)](https://maven-badges.herokuapp.com/maven-central/com.yahoo.bullet/bullet-bql) |
| **Package Manager Setup** | [Maven Central](https://search.maven.org/artifact/com.yahoo.bullet/bullet-bql/${bullet.bql.version}/jar) |

### Releases

|    Date      |                                  Release                                             |        JCenter        |      Maven Central    | Highlights | APIDocs |
| ------------ | ------------------------------------------------------------------------------------ | :-------------------: | :-------------------: | ---------- | ------- |
| 2021-09-01   | [**1.3.0**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-1.3.0)   |                       | <span>&#10003;</span> | Bullet Core 1.5.0. Nested (sub) queries and chained LATERAL VIEW EXPLODES | [JavaDocs](apidocs/bullet-bql/1.5.0/index.html) |
| 2021-08-02   | [**1.2.5**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-1.2.5)   |                       | <span>&#10003;</span> | Bullet Core 1.4.4 | [JavaDocs](apidocs/bullet-bql/1.2.5/index.html) |
| 2021-06-30   | [**1.2.4**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-1.2.4)   |                       | <span>&#10003;</span> | Bullet Core 1.4.2 | [JavaDocs](apidocs/bullet-bql/1.2.4/index.html) |
| 2021-06-28   | [**1.2.3**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-1.2.3)   |                       | <span>&#10003;</span> | Bug fix for LazyPubSubMessageSerDe clobbering the Metadata | [JavaDocs](apidocs/bullet-bql/1.2.3/index.html) |
| 2021-06-24   | [**1.2.2**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-1.2.2)   |                       | <span>&#10003;</span> | LazyPubSubMessageSerDe to do BQL in the backend | [JavaDocs](apidocs/bullet-bql/1.2.2/index.html) |
| 2021-06-09   | [**1.2.1**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-1.2.1)   |                       | <span>&#10003;</span> | UPPER, LOWER, MOD | [JavaDocs](apidocs/bullet-bql/1.2.1/index.html) |
| 2021-05-13   | [**1.2.0**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-1.2.0)   |                       | <span>&#10003;</span> | Bullet Core 1.3.1. EXPLODE, LATERAL VIEW, NOT RLIKE, NOT RLIKE ANY, TRIM, ABS, BETWEEN, NOT BETWEEN, SUBSTRING, UNIXTIMESTAMP | [JavaDocs](apidocs/bullet-bql/1.2.0/index.html) |
| 2021-04-22   | [**1.1.2**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-1.1.2)   |                       | <span>&#10003;</span> | First release on Maven Central. Bullet Core 1.2.2 | [JavaDocs](apidocs/bullet-bql/1.1.2/index.html) |
| 2021-04-22   | [**1.1.1**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-1.1.1)   | <span>&#10003;</span> |                       | Bullet Core 1.2.1 | [JavaDocs](apidocs/bullet-bql/1.1.1/index.html) |
| 2021-01-04   | [**1.1.0**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-1.1.0)   | <span>&#10003;</span> |                       | Bullet Core 1.2.0 | [JavaDocs](apidocs/bullet-bql/1.1.0/index.html) |
| 2021-01-04   | [**1.0.0**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-1.0.0)   | <span>&#10003;</span> |                       | Expressions, Schema integration, native queries instead of JSON | [JavaDocs](apidocs/bullet-bql/1.0.0/index.html) |
| 2018-11-28   | [**0.2.1**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-0.2.1)   | <span>&#10003;</span> |                       | Extended field access notation | [JavaDocs](apidocs/bullet-bql/0.2.1/index.html) |
| 2018-09-28   | [**0.2.0**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-0.2.0)   | <span>&#10003;</span> |                       | Adds Post Aggregations and uses bullet-core-0.5.1 | [JavaDocs](apidocs/bullet-bql/0.2.0/index.html) |
| 2018-09-06   | [**0.1.2**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-0.1.2)   | <span>&#10003;</span> |                       | Supports CONTAINSKEY, CONTAINSVALUE, SIZEOF, comparing to other fields. Fixes some bugs | [JavaDocs](apidocs/bullet-bql/0.1.2/index.html) |
| 2018-07-17   | [**0.1.1**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-0.1.1)   | <span>&#10003;</span> |                       | Stops publishing fat jar and marks slf4j dependency provided | [JavaDocs](apidocs/bullet-bql/0.1.1/index.html) |
| 2018-07-05   | [**0.1.0**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-0.1.0)   | <span>&#10003;</span> |                       | First release | |

