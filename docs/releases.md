# Releases

This sections gathers all the relevant releases of the three components of Bullet in one place. It may not include the very few initial releases of these components if they were largely irrelevant. Full release notes can be found by clicking on the actual releases.

Bullet is still in active development. We welcome all contributions. Feel free to raise any issues/questions/bugs and whatever else on the relevant issues section for each component. Please include as many details as you can.

## Bullet Core

The core Bullet logic (a library) that can be used to implement Bullet on different Stream Processors (like Flink, Storm, Kafka Streaming etc.). This core library can also be reused in other Bullet components that wish to depend on core Bullet concepts. This actually lived inside the [Bullet Storm](#bullet-storm) package prior to version [0.5.0](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.5.0). Starting with 0.5.0, Bullet Storm only includes the logic to implement Bullet on Storm.

|                           |                 |
| ------------------------- | --------------- |
| **Repository**            | [https://github.com/yahoo/bullet-core](https://github.com/yahoo/bullet-core) |
| **Issues**                | [https://github.com/yahoo/bullet-core/issues](https://github.com/yahoo/bullet-core/issues) |
| **Last Tag**              | [![Latest tag](https://img.shields.io/github/release/yahoo/bullet-core/all.svg)](https://github.com/yahoo/bullet-core/tags) |
| **Latest Artifact**       | [![Download](https://api.bintray.com/packages/yahoo/maven/bullet-core/images/download.svg)](https://bintray.com/yahoo/maven/bullet-core/_latestVersion) |
| **Package Manager Setup** | [Setup for Maven, Gradle etc](https://bintray.com/bintray/jcenter?filterByPkgName=bullet-core) |

### Releases

|    Date      |                                      Release                                      | Highlights |
| ------------ | --------------------------------------------------------------------------------- | ---------- |
| 2016-08-16   | [**0.2.0**](https://github.com/yahoo/bullet-core/releases/tag/bullet-core-0.2.0)  | PubSub interfaces and classes to implement custom communication between API and backend |
| 2016-06-27   | [**0.1.2**](https://github.com/yahoo/bullet-core/releases/tag/bullet-core-0.1.2)  | Changes to the BulletConfig interface previously used in Bullet Storm. Users now use BulletStormConfig instead but YAML config is the same |
| 2016-06-27   | [**0.1.1**](https://github.com/yahoo/bullet-core/releases/tag/bullet-core-0.1.1)  | First stable release containing the core of Bullet as a library including parsing, implementing queries, creating results, DataSketches etc |

## Bullet Record

The AVRO container that you need to convert your data into to be consumed by Bullet.

|                            |                 |
| -------------------------- | --------------- |
| **Repository**             | [https://github.com/yahoo/bullet-record](https://github.com/yahoo/bullet-record) |
| **Issues**                 | [https://github.com/yahoo/bullet-record/issues](https://github.com/yahoo/bullet-record/issues) |
| **Last Tag**               | [![Latest tag](https://img.shields.io/github/release/yahoo/bullet-record/all.svg)](https://github.com/yahoo/bullet-record/tags) |
| **Latest Artifact**        | [![Download](https://api.bintray.com/packages/yahoo/maven/bullet-record/images/download.svg)](https://bintray.com/yahoo/maven/bullet-record/_latestVersion) |
| **Package Manager Setup**  | [Setup for Maven, Gradle etc](https://bintray.com/bintray/jcenter?filterByPkgName=bullet-record) |

### Releases

|    Date      |                                  Release                                             | Highlights |
| ------------ | ------------------------------------------------------------------------------------ | ---------- |
| 2017-04-17   | [**0.1.1**](https://github.com/yahoo/bullet-record/releases/tag/bullet-record-0.1.0) | Helper methods to remove, rename, check presence and count fields in the Record |
| 2017-02-09   | [**0.1.0**](https://github.com/yahoo/bullet-record/releases/tag/bullet-record-0.1.0) | Map constructor |

## Bullet Storm

The implementation of Bullet on Storm. Due to major API changes between Storm <= 0.10 and Storm 1.0, Bullet Storm [builds two artifacts](backend/storm-setup.md#older-storm-versions). The ```artifactId``` changes from ```bullet-storm``` (for 1.0+) to ```bullet-storm-0.10```. All releases include migration and testing of the code on *both* versions. Both versions are built simultaneously. Feature parity depends on what was new in Storm 1.0. For example, the Resource Aware Scheduler or RAS, is only present in Storm 1.0+. So, bullet-storm-0.10 removes certain CPU and memory related settings specific to RAS in its configuration. There are also minor changes to the Metrics API in Storm. In terms of Bullet itself, there should be no differences.

!!! note "Future support"

    We will support Storm 0.10 for a bit longer till Storm 2.0 is up and stable. Storm versions 1.0+ have a lot of performance fixes and features that you should be running with.

|                               |                 |
| ----------------------------- | --------------- |
| **Storm-1.0+ Repository**     | [https://github.com/yahoo/bullet-storm](https://github.com/yahoo/bullet-storm) |
| **Storm-0.10- Repository**    | [https://github.com/yahoo/bullet-storm/tree/storm-0.10](https://github.com/yahoo/bullet-storm/tree/storm-0.10) |
| **Issues**                    | [https://github.com/yahoo/bullet-storm/issues](https://github.com/yahoo/bullet-storm/issues) |
| **Last Tag**                  | [![Latest tag](https://img.shields.io/github/release/yahoo/bullet-storm/all.svg)](https://github.com/yahoo/bullet-storm/tags) |
| **Latest Artifact**           | [![Download](https://api.bintray.com/packages/yahoo/maven/bullet-storm/images/download.svg)](https://bintray.com/yahoo/maven/bullet-storm/_latestVersion) |
| **Package Manager Setup**     | [Setup for Maven, Gradle etc](https://bintray.com/bintray/jcenter?filterByPkgName=bullet-storm) |

### Releases

|    Date      |                               Storm 1.0                                            |                                      Storm 0.10                                         | Highlights |
| ------------ | ---------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- | ---------- |
| 2017-06-27   | [**0.5.0**](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.5.0) | [**0.5.0**](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.10-0.5.0) | Pulled out Bullet Core. BulletConfig to BulletStormConfig |
| 2017-06-09   | [**0.4.3**](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.4.3) | [**0.4.3**](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.10-0.4.3) | Adding rounding for DISTRIBUTION. Latency metric |
| 2017-04-28   | [**0.4.2**](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.4.2) | [**0.4.2**](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.10-0.4.2) | Strict JSON output and fix for no data distributions |
| 2017-04-26   | [**0.4.1**](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.4.1) | [**0.4.1**](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.10-0.4.1) | Result Metadata Concept name mismatch fix |
| 2017-04-21   | [**0.4.0**](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.4.0) | [**0.4.0**](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.10-0.4.0) | DISTRIBUTION and TOP K release. Configuration renames. |
| 2017-03-13   | [**0.3.1**](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.3.1) | [**0.3.1**](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.10-0.3.1) | Extra records accepted after query expiry bug fix |
| 2017-02-27   | [**0.3.0**](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.3.0) | [**0.3.0**](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.10-0.3.0) | Metrics interface, config namespace, NPE bug fix |
| 2017-02-15   | [**0.2.1**](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.2.1) | [**0.2.1**](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.10-0.2.1) | Acking support, Max size and other bug fixes |
| 2017-01-26   | [**0.2.0**](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.2.0) | [**0.2.0**](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.10-0.2.0) | GROUP (DISTINCT, SUM, COUNT, MIN, MAX, AVG) |
| 2017-01-09   | [**0.1.0**](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.1.0) | [**0.1.0**](https://github.com/yahoo/bullet-storm/releases/tag/bullet-storm-0.10-0.1.0) | COUNT DISTINCT and micro-batching |

## Bullet Web Service

The Web Service implementation that can serve a static schema from a file and talk to the Storm backend.

|                            |                 |
| -------------------------- | --------------- |
| **Repository**             | [https://github.com/yahoo/bullet-service](https://github.com/yahoo/bullet-service) |
| **Issues**                 | [https://github.com/yahoo/bullet-service/issues](https://github.com/yahoo/bullet-service/issues) |
| **Last Tag**               | [![Latest tag](https://img.shields.io/github/release/yahoo/bullet-service/all.svg)](https://github.com/yahoo/bullet-service/tags) |
| **Latest Artifact**        | [![Download](https://api.bintray.com/packages/yahoo/maven/bullet-service/images/download.svg)](https://bintray.com/yahoo/maven/bullet-service/_latestVersion) |
| **Package Manager Setup**  | [Setup for Maven, Gradle etc](https://bintray.com/bintray/jcenter?filterByPkgName=bullet-service) |

### Releases

|    Date      |                                      Release                                           | Highlights |
| ------------ | -------------------------------------------------------------------------------------- | ---------- |
| 2016-12-16   | [**0.0.1**](https://github.com/yahoo/bullet-service/releases/tag/bullet-service-0.0.1) | The first release with support for DRPC and the file-based schema |

!!! note "Want to directly download jars?"

    Head over to the JCenter download page to [directly download all Bullet Storm, Core, Service, Record artifacts](http://jcenter.bintray.com/com/yahoo/bullet/).

## Bullet UI

The Bullet UI that lets you build, run, save and visualize results from Bullet.

|                     |                 |
| ------------------- | --------------- |
| **Repository**      | [https://github.com/yahoo/bullet-ui](https://github.com/yahoo/bullet-ui) |
| **Issues**          | [https://github.com/yahoo/bullet-ui/issues](https://github.com/yahoo/bullet-ui/issues) |
| **Last Tag**        | [![GitHub release](https://img.shields.io/github/tag/yahoo/bullet-ui.svg)](https://github.com/yahoo/bullet-ui/tags) |
| **Latest Artifact** | [![GitHub release](https://img.shields.io/github/release/yahoo/bullet-ui.svg)](https://github.com/yahoo/bullet-ui/releases/latest) |

### Releases

|    Date      |                                      Release                                           | Highlights |
| ------------ | -------------------------------------------------------------------------------------- | ---------- |
| 2016-08-22   | [**0.4.0**](https://github.com/yahoo/bullet-ui/releases/tag/v0.4.0) | Query sharing, collapsible Raw view, and unsaved/error indicators. Settings rename and other bug fixes|
| 2016-05-22   | [**0.3.2**](https://github.com/yahoo/bullet-ui/releases/tag/v0.3.2) | Exporting to TSV in Pivot table. Fixes unselectability bug in Raw view |
| 2016-05-15   | [**0.3.1**](https://github.com/yahoo/bullet-ui/releases/tag/v0.3.1) | Adds styles to the Pivot table. Fixes some minor UI interactions |
| 2016-05-10   | [**0.3.0**](https://github.com/yahoo/bullet-ui/releases/tag/v0.3.0) | Adds Charting and Pivoting support. Migrations enhanced. Support for overriding nested default settings |
| 2016-05-03   | [**0.2.2**](https://github.com/yahoo/bullet-ui/releases/tag/v0.2.2) | Fixes maxlength of the input for points |
| 2016-05-02   | [**0.2.1**](https://github.com/yahoo/bullet-ui/releases/tag/v0.2.1) | Fixes a bug with a dependency that broke sorting the Filters |
| 2016-05-01   | [**0.2.0**](https://github.com/yahoo/bullet-ui/releases/tag/v0.2.0) | Release for Top K and Distribution. Supports Bullet Storm 0.4.2+ |
| 2016-02-21   | [**0.1.0**](https://github.com/yahoo/bullet-ui/releases/tag/v0.1.0) | The first release with support for all features included in Bullet Storm 0.2.1+ |
