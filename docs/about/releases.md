# Releases

This sections gathers all the relevant releases of the three components of Bullet in one place. It may not include the very few initial releases of these components if they were largely irrelevant. Full release notes can be found by clicking on the actual releases.

Bullet is still in active development. We welcome all contributions. Feel free to raise any issues/questions/bugs and whatever else on the relevant issues section for each component. Please include as many details as you can.

## Bullet Storm

The implementation of Bullet on Storm. Due to major API changes between Storm <= 0.10 and Storm 1.0, Bullet Storm [builds two artifacts](../backend/setup-storm.md#older-storm-versions). The ```artifactId``` changes from ```bullet-storm``` (for 1.0+) to ```bullet-storm-0.10```.
All releases include migration and testing of the code on *both* versions. Both versions are built simultaneously. Feature parity depends on what was new in Storm 1.0. For example, the Resource Aware Scheduler or RAS, is only present in Storm 1.0+. So, bullet-storm-0.10 removes
certain CPU and memory related settings specific to RAS in its configuration. There are also minor changes to the Metrics API in Storm. In terms of Bullet itself, there should be no differences.

!!! note "Future support"

    We will support Storm 0.10 for a bit longer till Storm 2.0 is up and stable. Storm versions 1.0+ have a lot of performance fixes and features that you should be running with.

|                               |                 |
| ----------------------------- | --------------- |
| **Storm-1.0+ Repository**     | [https://github.com/yahoo/bullet-storm](https://github.com/yahoo/bullet-storm) |
| **Storm-0.10- Repository**    | [https://github.com/yahoo/bullet-storm/tree/storm-0.10](https://github.com/yahoo/bullet-storm/tree/storm-0.10) |
| **Issues**                    | [https://github.com/yahoo/bullet-storm/issues](https://github.com/yahoo/bullet-storm/issues) |
| **Last Tag**                  | [![Latest tag](https://img.shields.io/github/release/yahoo/bullet-storm.svg)](https://github.com/yahoo/bullet-storm/releases/latest) |
| **Latest Artifact**           | [![Download](https://api.bintray.com/packages/yahoo/maven/bullet-storm/images/download.svg)](https://bintray.com/yahoo/maven/bullet-storm/_latestVersion) |

### Releases

|    Date      |                               Storm 1.0                                            |                                      Storm 0.10                                         | Highlights |
| ------------ | ---------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- | ---------- |
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

|                     |                 |
| ------------------- | --------------- |
| **Repository**      | [https://github.com/yahoo/bullet-service](https://github.com/yahoo/bullet-service) |
| **Issues**          | [https://github.com/yahoo/bullet-service/issues](https://github.com/yahoo/bullet-service/issues) |
| **Last Tag**        | [![Latest tag](https://img.shields.io/github/release/yahoo/bullet-service.svg)](https://github.com/yahoo/bullet-service/releases/latest) |
| **Latest Artifact** | [![Download](https://api.bintray.com/packages/yahoo/maven/bullet-service/images/download.svg)](https://bintray.com/yahoo/maven/bullet-service/_latestVersion) |

### Releases

|    Date      |                                      Release                                           | Highlights |
| ------------ | -------------------------------------------------------------------------------------- | ---------- |
| 2016-12-16   | [**0.0.1**](https://github.com/yahoo/bullet-service/releases/tag/bullet-service-0.0.1) | The first release with support for DRPC and the file-based schema |

## Bullet UI

The Bullet UI that lets you build, run, save and visualize results from Bullet.

|                     |                 |
| ------------------- | --------------- |
| **Repository**      | [https://github.com/yahoo/bullet-ui](https://github.com/yahoo/bullet-ui) |
| **Issues**          | [https://github.com/yahoo/bullet-ui/issues](https://github.com/yahoo/bullet-ui/issues) |
| **Last Tag**        | [![GitHub release](https://img.shields.io/github/release/yahoo/bullet-ui.svg)](https://github.com/yahoo/bullet-ui/releases/latest) |
| **Latest Artifact** | [![GitHub release](https://img.shields.io/github/release/yahoo/bullet-ui.svg)](https://github.com/yahoo/bullet-ui/releases/latest) |

### Releases

|    Date      |                                      Release                                           | Highlights |
| ------------ | -------------------------------------------------------------------------------------- | ---------- |
| 2016-05-03   | [**0.2.2**](https://github.com/yahoo/bullet-ui/releases/tag/v0.2.2) | Fixes maxlength of the input for points |
| 2016-05-02   | [**0.2.1**](https://github.com/yahoo/bullet-ui/releases/tag/v0.2.1) | Fixes a bug with a dependency that broke sorting the Filters |
| 2016-05-01   | [**0.2.0**](https://github.com/yahoo/bullet-ui/releases/tag/v0.2.0) | Release for Top K and Distribution. Supports Bullet Storm 0.4.2+ |
| 2016-02-21   | [**0.1.0**](https://github.com/yahoo/bullet-ui/releases/tag/v0.1.0) | The first release with support for all features included in Bullet Storm 0.2.1+ |

## Bullet Record

The AVRO container that you need to convert your data into to be consumed by Bullet.

|                     |                 |
| ------------------- | --------------- |
| **Repository**      | [https://github.com/yahoo/bullet-record](https://github.com/yahoo/bullet-record) |
| **Issues**          | [https://github.com/yahoo/bullet-record/issues](https://github.com/yahoo/bullet-record/issues) |
| **Last Tag**        | [![Latest tag](https://img.shields.io/github/release/yahoo/bullet-record.svg)](https://github.com/yahoo/bullet-record/releases/latest) |
| **Latest Artifact** | [![Download](https://api.bintray.com/packages/yahoo/maven/bullet-record/images/download.svg)](https://bintray.com/yahoo/maven/bullet-record/_latestVersion) |

### Releases

|    Date      |                                  Release                                             | Highlights |
| ------------ | ------------------------------------------------------------------------------------ | ---------- |
| 2017-04-17   | [**0.1.1**](https://github.com/yahoo/bullet-record/releases/tag/bullet-record-0.1.0) | Helper methods to remove, rename, check presence and count fields in the Record |
| 2017-02-09   | [**0.1.0**](https://github.com/yahoo/bullet-record/releases/tag/bullet-record-0.1.0) | Map constructor |
