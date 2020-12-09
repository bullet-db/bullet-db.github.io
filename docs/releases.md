# Releases

This sections gathers all the relevant releases of the components of Bullet that we maintain in one place. It may not include the very few initial releases of these components if they were largely irrelevant. Full release notes can be found by clicking on the actual releases.

Bullet is still in active development. We welcome all contributions. Feel free to raise any issues/questions/bugs and whatever else on the relevant issues section for each component. Please include as many details as you can.

## API Documentation

API (Java and Scala) docs can also be found for the releases below.

## Download

For downloading any artifact listed below manually, you should preferably use the [**JCenter mirror here**](https://jcenter.bintray.com/com/yahoo/bullet/). For resolving artifacts in your build tool, follow the directions in each of the components' Package Manager Setup sections.

-----

## Bullet Core

The core Bullet logic (a library) that can be used to implement Bullet on different Stream Processors (like Flink, Storm, Kafka Streams etc.). This core library can also be reused in other Bullet components that wish to depend on core Bullet concepts. This actually lived inside the [Bullet Storm](#bullet-storm) package prior to version [0.5.0](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.5.0). Starting with 0.5.0, Bullet Storm only includes the logic to implement Bullet on Storm.

|                           |                 |
| ------------------------- | --------------- |
| **Repository**            | [https://github.com/bullet-db/bullet-core](https://github.com/bullet-db/bullet-core) |
| **Issues**                | [https://github.com/bullet-db/bullet-core/issues](https://github.com/bullet-db/bullet-core/issues) |
| **Last Tag**              | [![Latest tag](https://img.shields.io/github/release/bullet-db/bullet-core/all.svg)](https://github.com/bullet-db/bullet-core/tags) |
| **Latest Artifact**       | [![Download](https://api.bintray.com/packages/yahoo/maven/bullet-core/images/download.svg)](https://bintray.com/yahoo/maven/bullet-core/_latestVersion) |
| **Package Manager Setup** | [Setup for Maven, Gradle etc](https://bintray.com/bintray/jcenter?filterByPkgName=bullet-core) |

### Releases

|    Date      |                                        Release                                        | Highlights | APIDocs |
| ------------ | ------------------------------------------------------------------------------------- | ---------- | ------- |
| 2019-02-01   | [**0.6.6**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.6.6)  | QueryManager partition leak cleanup | [JavaDocs](apidocs/bullet-core/0.6.6/index.html) |
| 2018-12-20   | [**0.6.5**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.6.5)  | QueryManager logging fixes | [JavaDocs](apidocs/bullet-core/0.6.5/index.html) |
| 2018-11-21   | [**0.6.4**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.6.4)  | Extended field extraction in Projections | [JavaDocs](apidocs/bullet-core/0.6.4/index.html) |
| 2018-11-21   | [**0.6.3**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.6.3)  | Extended field extraction Filters and Aggregations | [JavaDocs](apidocs/bullet-core/0.6.3/index.html) |
| 2018-11-19   | [**0.6.2**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.6.2)  | Query Manager helpers | [JavaDocs](apidocs/bullet-core/0.6.2/index.html) |
| 2018-11-16   | [**0.6.1**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.6.1)  | Query Categorizer category | [JavaDocs](apidocs/bullet-core/0.6.1/index.html) |
| 2018-11-06   | [**0.6.0**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.6.0)  | Query Partitioning, Validator and other improvements | [JavaDocs](apidocs/bullet-core/0.6.0/index.html) |
| 2018-10-21   | [**0.5.2**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.5.2)  | AutoCloseable Pubsub Components, HttpClient 4.3.6 | [JavaDocs](apidocs/bullet-core/0.5.2/index.html) |
| 2018-09-25   | [**0.5.1**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.5.1)  | Better Order By, Smaller Serializations, Transient Fields | [JavaDocs](apidocs/bullet-core/0.5.1/index.html) |
| 2018-09-14   | [**0.5.0**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.5.0)  | Post Aggregations - ORDER BY, COMPUTATION, Casting in Filters | [JavaDocs](apidocs/bullet-core/0.5.0/index.html) |
| 2018-09-05   | [**0.4.3**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.4.3)  | Sliding Windows, SIZEIS, CONTAINSKEY, CONTAINSVALUE, filtering against other fields | [JavaDocs](apidocs/bullet-core/0.4.3/index.html) |
| 2018-06-26   | [**0.4.2**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.4.2)  | Fixes a bug with unclosed connections in the RESTPubSub | [JavaDocs](apidocs/bullet-core/0.4.2/index.html) |
| 2018-06-22   | [**0.4.1**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.4.1)  | Added RESTPublisher HTTP Timeout Setting | |
| 2018-06-18   | [**0.4.0**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.4.0)  | Added support for Integer and Float data types, and configurable BulletRecordProvider class used to instantiate BulletRecords in bullet-core | |
| 2018-04-11   | [**0.3.4**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.3.4)  | Pre-Start delaying and Buffering changes - queries are now buffered at the start of a query instead of start of each window | |
| 2018-03-30   | [**0.3.3**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.3.3)  | Bug fix for com.yahoo.bullet.core.querying.Querier#isClosedForPartition | |
| 2018-03-20   | [**0.3.2**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.3.2)  | Added headers to RESTPubSub http requests | |
| 2018-03-16   | [**0.3.1**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.3.1)  | Added RESTPubSub implementation | |
| 2018-02-22   | [**0.3.0**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.3.0)  | Supports windowing / incremental updates | |
| 2017-10-04   | [**0.2.5**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.2.5)  | Supports an in-memory BufferingSubscriber implementation for reliable subscribing | |
| 2017-10-03   | [**0.2.4**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.2.4)  | Helpers added to Config, PubSubMessage, Metadata and JSONFormatter. FAIL signal in Metadata. PubSubMessage is JSON serializable | |
| 2017-09-20   | [**0.2.3**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.2.3)  | PubSub is no longer required to be Serializable. Makes PubSubMessage fully serializable. Utility classes and checked exceptions for PubSub | |
| 2017-08-30   | [**0.2.2**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.2.2)  | Helper methods to PubSubMessage and Config | |
| 2017-08-23   | [**0.2.1**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.2.1)  | Removes PubSubConfig, adds defaults methods to Publisher/Subscriber interfaces and improves PubSubException | |
| 2017-08-16   | [**0.2.0**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.2.0)  | PubSub interfaces and classes to implement custom communication between API and backend | |
| 2017-06-27   | [**0.1.2**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.1.2)  | Changes to the BulletConfig interface previously used in Bullet Storm. Users now use BulletStormConfig instead but YAML config is the same | |
| 2017-06-27   | [**0.1.1**](https://github.com/bullet-db/bullet-core/releases/tag/bullet-core-0.1.1)  | First stable release containing the core of Bullet as a library including parsing, implementing queries, creating results, DataSketches etc | |

## Bullet Storm

The implementation of Bullet on Storm. Due to major API changes between Storm <= 0.10 and Storm 1.0, Bullet Storm [builds two artifacts](backend/storm-setup.md#older-storm-versions). The ```artifactId``` changes from ```bullet-storm``` (for 1.0+) to ```bullet-storm-0.10```. All releases include migration and testing of the code on *both* versions. Both versions are built simultaneously. Feature parity depends on what was new in Storm 1.0. For example, the Resource Aware Scheduler or RAS, is only present in Storm 1.0+. So, bullet-storm-0.10 removes certain CPU and memory related settings specific to RAS in its configuration. There are also minor changes to the Metrics API in Storm. In terms of Bullet itself, there should be no differences.

!!! note "Storm DRPC PubSub "

    The DRPC PubSub is part of this artifact and is fully released and available for use starting with versions 0.6.2 and above. It is only meant to be used if you're using Storm as your Backend.

!!! note "Future support"

    We will support Storm 0.10 for a bit longer till Storm 2.0 is up and stable. Storm versions 1.0+ have a lot of performance fixes and features that you should be running with.

|                               |                 |
| ----------------------------- | --------------- |
| **Storm-1.0+ Repository**     | [https://github.com/bullet-db/bullet-storm](https://github.com/bullet-db/bullet-storm) |
| **Storm-0.10- Repository**    | [https://github.com/bullet-db/bullet-storm/tree/storm-0.10](https://github.com/bullet-db/bullet-storm/tree/storm-0.10) |
| **Issues**                    | [https://github.com/bullet-db/bullet-storm/issues](https://github.com/bullet-db/bullet-storm/issues) |
| **Last Tag**                  | [![Latest tag](https://img.shields.io/github/release/bullet-db/bullet-storm/all.svg)](https://github.com/bullet-db/bullet-storm/tags) |
| **Latest Artifact**           | [![Download](https://api.bintray.com/packages/yahoo/maven/bullet-storm/images/download.svg)](https://bintray.com/yahoo/maven/bullet-storm/_latestVersion) |
| **Package Manager Setup**     | [Setup for Maven, Gradle etc](https://bintray.com/bintray/jcenter?filterByPkgName=bullet-storm) |

### Releases

|    Date      |                            Storm 1.0                                        |                                 Storm 0.10                                  | Highlights | APIDocs |
| ------------ | --------------------------------------------------------------------------- | --------------------------------------------------------------------------- | ---------- | ------- |
| 2019-02-07   | [**0.9.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.9.1) | [**0.9.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.9.1) | Bullet DSL 0.1.2 and packaging fixes | [JavaDocs](apidocs/bullet-storm/0.9.1/index.html) |
| 2019-02-07   | [**0.9.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.9.0) | [**0.9.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.9.0) | Bullet DSL support! | [JavaDocs](apidocs/bullet-storm/0.9.0/index.html) |
| 2018-11-26   | [**0.8.5**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.8.5) | [**0.8.5**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.8.5) | Extended field notation and updates bullet-core to 0.6.4| [JavaDocs](apidocs/bullet-storm/0.8.5/index.html) |
| 2018-11-20   | [**0.8.4**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.8.4) | [**0.8.4**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.8.4) | Partitioning and updates bullet-core to 0.6.2 | [JavaDocs](apidocs/bullet-storm/0.8.4/index.html) |
| 2018-06-18   | [**0.8.3**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.8.3) | [**0.8.3**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.8.3) | Using new bullet-record and bullet-core supporting Integer and Float data types | [JavaDocs](apidocs/bullet-storm/0.8.3/index.html) |
| 2018-04-12   | [**0.8.2**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.8.2) | [**0.8.2**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.8.2) | Delaying query start in Join bolt | |
| 2018-04-04   | [**0.8.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.8.1) | [**0.8.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.8.1) | Fixed bug in Joinbolt | |
| 2018-03-30   | [**0.8.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.8.0) | [**0.8.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.8.0) | Supports windowing / incremental updates | |
| 2017-11-07   | [**0.7.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.7.0) | [**0.7.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.7.0) | Merge Query and Metadata Streams | |
| 2017-10-24   | [**0.6.2**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.6.2) | [**0.6.2**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.6.2) | Adds a fat jar for using the DRPC PubSub in the Web Service | |
| 2017-10-18   | [**0.6.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.6.1) | [**0.6.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.6.1) | DRPC PubSub | |
| 2017-08-30   | [**0.6.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.6.0) | [**0.6.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.6.0) | New PubSub architecture, removes DRPC components and settings | |
| 2017-06-27   | [**0.5.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.5.0) | [**0.5.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.5.0) | Pulled out Bullet Core. BulletConfig to BulletStormConfig | |
| 2017-06-09   | [**0.4.3**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.4.3) | [**0.4.3**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.4.3) | Adding rounding for DISTRIBUTION. Latency metric | |
| 2017-04-28   | [**0.4.2**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.4.2) | [**0.4.2**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.4.2) | Strict JSON output and fix for no data distributions | |
| 2017-04-26   | [**0.4.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.4.1) | [**0.4.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.4.1) | Result Metadata Concept name mismatch fix | |
| 2017-04-21   | [**0.4.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.4.0) | [**0.4.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.4.0) | DISTRIBUTION and TOP K release. Configuration renames. | |
| 2017-03-13   | [**0.3.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.3.1) | [**0.3.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.3.1) | Extra records accepted after query expiry bug fix | |
| 2017-02-27   | [**0.3.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.3.0) | [**0.3.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.3.0) | Metrics interface, config namespace, NPE bug fix | |
| 2017-02-15   | [**0.2.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.2.1) | [**0.2.1**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.2.1) | Acking support, Max size and other bug fixes | |
| 2017-01-26   | [**0.2.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.2.0) | [**0.2.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.2.0) | GROUP (DISTINCT, SUM, COUNT, MIN, MAX, AVG) | |
| 2017-01-09   | [**0.1.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.1.0) | [**0.1.0**](https://github.com/bullet-db/bullet-storm/releases/tag/bullet-storm-0.10-0.1.0) | COUNT DISTINCT and micro-batching | |

## Bullet Spark

The implementation of Bullet on Spark Streaming.

|                           |                 |
| ------------------------- | --------------- |
| **Repository**            | [https://github.com/bullet-db/bullet-spark](https://github.com/bullet-db/bullet-spark) |
| **Issues**                | [https://github.com/bullet-db/bullet-spark/issues](https://github.com/bullet-db/bullet-spark/issues) |
| **Last Tag**              | [![Latest tag](https://img.shields.io/github/release/bullet-db/bullet-spark/all.svg)](https://github.com/bullet-db/bullet-spark/tags) |
| **Latest Artifact**       | [![Download](https://api.bintray.com/packages/yahoo/maven/bullet-spark/images/download.svg)](https://bintray.com/yahoo/maven/bullet-spark/_latestVersion) |
| **Package Manager Setup** | [Setup for Maven, Gradle etc](https://bintray.com/bintray/jcenter?filterByPkgName=bullet-spark) |

### Releases

|    Date      |                                      Release                                      | Highlights | APIDocs |
| ------------ | --------------------------------------------------------------------------------- | ---------- | ------- |
| 2019-02-07   | [**0.2.2**](https://github.com/bullet-db/bullet-spark/releases/tag/bullet-spark-0.2.2)  | Fixes a NPE in JoinStreaming for very short queries | [SparkDocs](apidocs/bullet-spark/0.2.2/index.html) |
| 2018-11-26   | [**0.2.1**](https://github.com/bullet-db/bullet-spark/releases/tag/bullet-spark-0.2.1)  | Uses bullet-core 0.6.4 and supports extended field notation in queries | [SparkDocs](apidocs/bullet-spark/0.2.1/index.html) |
| 2018-11-16   | [**0.2.0**](https://github.com/bullet-db/bullet-spark/releases/tag/bullet-spark-0.2.0)  | Uses bullet-core 0.6.1 and adds partitioning support | [SparkDocs](apidocs/bullet-spark/0.2.0/index.html) |
| 2018-06-18   | [**0.1.2**](https://github.com/bullet-db/bullet-spark/releases/tag/bullet-spark-0.1.2)  | Uses SimpleBulletRecord to avoid some Spark serialization issues with Avro | [SparkDocs](apidocs/bullet-spark/0.1.2/index.html) |
| 2018-06-08   | [**0.1.1**](https://github.com/bullet-db/bullet-spark/releases/tag/bullet-spark-0.1.1)  | Adds a command flag to pass custom setting file | |
| 2018-05-25   | [**0.1.0**](https://github.com/bullet-db/bullet-spark/releases/tag/bullet-spark-0.1.0)  | The first release | |

## Bullet Web Service

The Web Service implementation that can serve a static schema from a file and talk to the backend using the PubSub.

!!! note "WAR to JAR"

    Starting with 0.1.1 and above, this artifact no longer produces a WAR file that is meant to be run in a servlet container and instead switches to an executable Java application using Spring Boot.

|                            |                 |
| -------------------------- | --------------- |
| **Repository**             | [https://github.com/bullet-db/bullet-service](https://github.com/bullet-db/bullet-service) |
| **Issues**                 | [https://github.com/bullet-db/bullet-service/issues](https://github.com/bullet-db/bullet-service/issues) |
| **Last Tag**               | [![Latest tag](https://img.shields.io/github/release/bullet-db/bullet-service/all.svg)](https://github.com/bullet-db/bullet-service/tags) |
| **Latest Artifact**        | [![Download](https://api.bintray.com/packages/yahoo/maven/bullet-service/images/download.svg)](https://bintray.com/yahoo/maven/bullet-service/_latestVersion) |
| **Package Manager Setup**  | [Setup for Maven, Gradle etc](https://bintray.com/bintray/jcenter?filterByPkgName=bullet-service) |

### Releases

|    Date      |                                      Release                                           | Highlights | APIDocs |
| ------------ | -------------------------------------------------------------------------------------- | ---------- | ------- |
| 2019-03-07   | [**0.5.0**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.5.0) | QueryManager API updates | [JavaDocs](apidocs/bullet-service/0.5.0/index.html) |
| 2018-11-28   | [**0.4.3**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.4.3) | Updates bullet-bql to 0.2.1 | [JavaDocs](apidocs/bullet-service/0.4.3/index.html) |
| 2018-11-26   | [**0.4.2**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.4.2) | BQL to JSON endpoint, dead backend reaper, new types in Schema, bullet-core 0.6.4 | [JavaDocs](apidocs/bullet-service/0.4.2/index.html) |
| 2018-09-06   | [**0.4.1**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.4.1) | Max Queries limit and bullet-bql 0.1.2 | [JavaDocs](apidocs/bullet-service/0.4.1/index.html) |
| 2018-07-17   | [**0.4.0**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.4.0) | Enhanced Web Service to support BQL queries | [JavaDocs](apidocs/bullet-service/0.4.0/index.html) |
| 2018-06-25   | [**0.3.0**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.3.0) | Upgrades to Netty-less Bullet Core for the RESTPubsub | |
| 2018-06-14   | [**0.2.2**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.2.2) | Adding settings to configure Websocket | |
| 2018-04-02   | [**0.2.1**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.2.1) | Moved and renamed settings | |
| 2018-03-30   | [**0.2.0**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.2.0) | Supporting windowing / incremental updates | |
| 2017-10-19   | [**0.1.1**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.1.1) | New PubSub architecture. Switching to Spring Boot and executable JAR instead of WAR | |
| 2016-12-16   | [**0.0.1**](https://github.com/bullet-db/bullet-service/releases/tag/bullet-service-0.0.1) | The first release with support for DRPC and the file-based schema | |

!!! note "Want to directly download jars?"

    Head over to the JCenter download page to [directly download all Bullet Storm, Core, Service, Record artifacts](http://jcenter.bintray.com/com/yahoo/bullet/).

## Bullet UI

The Bullet UI that lets you build, run, save and visualize results from Bullet.

|                     |                 |
| ------------------- | --------------- |
| **Repository**      | [https://github.com/bullet-db/bullet-ui](https://github.com/bullet-db/bullet-ui) |
| **Issues**          | [https://github.com/bullet-db/bullet-ui/issues](https://github.com/bullet-db/bullet-ui/issues) |
| **Last Tag**        | [![GitHub release](https://img.shields.io/github/tag/bullet-db/bullet-ui.svg)](https://github.com/bullet-db/bullet-ui/tags) |
| **Latest Artifact** | [![GitHub release](https://img.shields.io/github/release/bullet-db/bullet-ui.svg)](https://github.com/bullet-db/bullet-ui/releases/latest) |

### Releases

|    Date      |                                      Release                                           | Highlights |
| ------------ | -------------------------------------------------------------------------------------- | ---------- |
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

The AVRO container that you need to convert your data into to be consumed by Bullet.

|                            |                 |
| -------------------------- | --------------- |
| **Repository**             | [https://github.com/bullet-db/bullet-record](https://github.com/bullet-db/bullet-record) |
| **Issues**                 | [https://github.com/bullet-db/bullet-record/issues](https://github.com/bullet-db/bullet-record/issues) |
| **Last Tag**               | [![Latest tag](https://img.shields.io/github/release/bullet-db/bullet-record/all.svg)](https://github.com/bullet-db/bullet-record/tags) |
| **Latest Artifact**        | [![Download](https://api.bintray.com/packages/yahoo/maven/bullet-record/images/download.svg)](https://bintray.com/yahoo/maven/bullet-record/_latestVersion) |
| **Package Manager Setup**  | [Setup for Maven, Gradle etc](https://bintray.com/bintray/jcenter?filterByPkgName=bullet-record) |

### Releases

|    Date      |                                  Release                                             | Highlights | APIDocs |
| ------------ | ------------------------------------------------------------------------------------ | ---------- | ------- |
| 2018-11-21   | [**0.3.0**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-0.3.0) | More setters in BulletRecord including a forceSet | [JavaDocs](apidocs/bullet-record/0.3.0/index.html) |
| 2018-10-30   | [**0.2.2**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-0.2.2) | Extract from Lists and Map of Maps | [JavaDocs](apidocs/bullet-record/0.2.2/index.html) |
| 2018-08-14   | [**0.2.1**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-0.2.1) | Supports List of Primitive types | [JavaDocs](apidocs/bullet-record/0.2.1/index.html) |
| 2018-06-14   | [**0.2.0**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-0.2.0) | Makes BulletRecord pluggable, adds simple record and avro record implementations | [JavaDocs](apidocs/bullet-record/0.2.0/index.html) |
| 2017-05-19   | [**0.1.2**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-0.1.2) | Reduces the memory footprint needed to serialize itself by a factor of 128 for small records | |
| 2017-04-17   | [**0.1.1**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-0.1.1) | Helper methods to remove, rename, check presence and count fields in the Record | |
| 2017-02-09   | [**0.1.0**](https://github.com/bullet-db/bullet-record/releases/tag/bullet-record-0.1.0) | Map constructor | |

## Bullet DSL

A DSL to plug data sources into the Bullet Backend and Web Service.

|                            |                 |
| -------------------------- | --------------- |
| **Repository**             | [https://github.com/bullet-db/bullet-dsl](https://github.com/bullet-db/bullet-dsl) |
| **Issues**                 | [https://github.com/bullet-db/bullet-dsl/issues](https://github.com/bullet-db/bullet-dsl/issues) |
| **Last Tag**               | [![Latest tag](https://img.shields.io/github/release/bullet-db/bullet-dsl/all.svg)](https://github.com/bullet-db/bullet-dsl/tags) |
| **Latest Artifact**        | [![Download](https://api.bintray.com/packages/yahoo/maven/bullet-dsl/images/download.svg)](https://bintray.com/yahoo/maven/bullet-dsl/_latestVersion) |
| **Package Manager Setup**  | [Setup for Maven, Gradle etc](https://bintray.com/bintray/jcenter?filterByPkgName=bullet-dsl) |

### Releases

|    Date      |                                  Release                                                 | Highlights | APIDocs |
| ------------ | ---------------------------------------------------------------------------------------- | ---------- | ------- |
| 2019-02-07   | [**0.1.2**](https://github.com/bullet-db/bullet-dsl/releases/tag/bullet-dsl-0.1.2) | Thinner Fat jar | [JavaDocs](apidocs/bullet-dsl/0.1.2/index.html) |
| 2019-02-07   | [**0.1.1**](https://github.com/bullet-db/bullet-dsl/releases/tag/bullet-dsl-0.1.1) | Interface consolidation, IdentityDeserializer | [JavaDocs](apidocs/bullet-dsl/0.1.1/index.html) |
| 2019-02-05   | [**0.1.0**](https://github.com/bullet-db/bullet-dsl/releases/tag/bullet-dsl-0.1.0) | Bullet DSL, Fat jar, Interface refactors | [JavaDocs](apidocs/bullet-dsl/0.1.0/index.html) |
| 2019-01-08   | [**0.0.1**](https://github.com/bullet-db/bullet-dsl/releases/tag/bullet-dsl-0.0.1) | First release | [JavaDocs](apidocs/bullet-dsl/0.0.1/index.html) |

## Bullet Kafka

A PubSub implementation using Kafka as the backing PubSub. Can be used with any Bullet Backend.

|                            |                 |
| -------------------------- | --------------- |
| **Repository**             | [https://github.com/bullet-db/bullet-kafka](https://github.com/bullet-db/bullet-kafka) |
| **Issues**                 | [https://github.com/bullet-db/bullet-kafka/issues](https://github.com/bullet-db/bullet-kafka/issues) |
| **Last Tag**               | [![Latest tag](https://img.shields.io/github/release/bullet-db/bullet-kafka/all.svg)](https://github.com/bullet-db/bullet-kafka/tags) |
| **Latest Artifact**        | [![Download](https://api.bintray.com/packages/yahoo/maven/bullet-kafka/images/download.svg)](https://bintray.com/yahoo/maven/bullet-kafka/_latestVersion) |
| **Package Manager Setup**  | [Setup for Maven, Gradle etc](https://bintray.com/bintray/jcenter?filterByPkgName=bullet-kafka) |

### Releases

|    Date      |                                  Release                                             | Highlights | APIDocs |
| ------------ | ------------------------------------------------------------------------------------ | ---------- | ------- |
| 2018-12-17   | [**0.3.3**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-0.3.3) | Removes adding unnecessary properties to Producers/Consumers | [JavaDocs](apidocs/bullet-kafka/0.3.3/index.html) |
| 2018-11-26   | [**0.3.2**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-0.3.2) | Uses bullet-core-0.6.4 | [JavaDocs](apidocs/bullet-kafka/0.3.2/index.html) |
| 2018-11-26   | [**0.3.1**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-0.3.1) | Uses bullet-core-0.6.0 and adds Validator | [JavaDocs](apidocs/bullet-kafka/0.3.1/index.html) |
| 2018-02-27   | [**0.3.0**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-0.3.0) | Uses bullet-core-0.3.0 - windows / incremental updates | [JavaDocs](apidocs/bullet-kafka/0.3.0/index.html) |
| 2017-10-19   | [**0.2.0**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-0.2.0) | Refactors and re-releases. Pass-through settings to Kafka. Manual offset committing bug fix | |
| 2017-09-27   | [**0.1.2**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-0.1.2) | Fixes a bug with config loading | |
| 2017-09-22   | [**0.1.1**](https://github.com/bullet-db/bullet-kafka/releases/tag/bullet-kafka-0.1.1) | First release using the PubSub interfaces | |

## Bullet Pulsar

A PubSub implementation using Pulsar as the backing PubSub. Can be used with any Bullet Backend.

|                            |                 |
| -------------------------- | --------------- |
| **Repository**             | [https://github.com/bullet-db/bullet-pulsar](https://github.com/bullet-db/bullet-pulsar) |
| **Issues**                 | [https://github.com/bullet-db/bullet-pulsar/issues](https://github.com/bullet-db/bullet-pulsar/issues) |
| **Last Tag**               | [![Latest tag](https://img.shields.io/github/release/bullet-db/bullet-pulsar/all.svg)](https://github.com/bullet-db/bullet-pulsar/tags) |
| **Latest Artifact**        | [![Download](https://api.bintray.com/packages/yahoo/maven/bullet-pulsar/images/download.svg)](https://bintray.com/yahoo/maven/bullet-pulsar/_latestVersion) |
| **Package Manager Setup**  | [Setup for Maven, Gradle etc](https://bintray.com/bintray/jcenter?filterByPkgName=bullet-pulsar) |

### Releases

|    Date      |                                  Release                                                 | Highlights | APIDocs |
| ------------ | ---------------------------------------------------------------------------------------- | ---------- | ------- |
| 2018-12-10   | [**0.1.0**](https://github.com/bullet-db/bullet-pulsar/releases/tag/bullet-pulsar-0.1.0) | First release using the PubSub interfaces | [JavaDocs](apidocs/bullet-pulsar/0.1.0/index.html) |

## Bullet BQL

A library facilitating the creation of Bullet queries from a SQL-like query language called BQL.

|                            |                 |
| -------------------------- | --------------- |
| **Repository**             | [https://github.com/bullet-db/bullet-bql](https://github.com/bullet-db/bullet-bql) |
| **Issues**                 | [https://github.com/bullet-db/bullet-bql/issues](https://github.com/bullet-db/bullet-bql/issues) |
| **Last Tag**               | [![Latest tag](https://img.shields.io/github/release/bullet-db/bullet-bql/all.svg)](https://github.com/bullet-db/bullet-bql/tags) |
| **Latest Artifact**        | [![Download](https://api.bintray.com/packages/yahoo/maven/bullet-bql/images/download.svg)](https://bintray.com/yahoo/maven/bullet-bql/_latestVersion) |
| **Package Manager Setup**  | [Setup for Maven, Gradle etc](https://bintray.com/bintray/jcenter?filterByPkgName=bullet-bql) |

### Releases

|    Date      |                                  Release                                             | Highlights | APIDocs |
| ------------ | ------------------------------------------------------------------------------------ | ---------- | ------- |
| 2018-11-28   | [**0.2.1**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-0.2.1) | Extended field access notation | [JavaDocs](apidocs/bullet-bql/0.2.1/index.html) |
| 2018-09-28   | [**0.2.0**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-0.2.0) | Adds Post Aggregations and uses bullet-core-0.5.1 | [JavaDocs](apidocs/bullet-bql/0.2.0/index.html) |
| 2018-09-06   | [**0.1.2**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-0.1.2) | Supports CONTAINSKEY, CONTAINSVALUE, SIZEOF, comparing to other fields. Fixes some bugs | [JavaDocs](apidocs/bullet-bql/0.1.2/index.html) |
| 2018-07-17   | [**0.1.1**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-0.1.1) | Stops publishing fat jar and marks slf4j dependency provided | [JavaDocs](apidocs/bullet-bql/0.1.1/index.html) |
| 2018-07-05   | [**0.1.0**](https://github.com/bullet-db/bullet-bql/releases/tag/bullet-bql-0.1.0) | First release | |
