# Overview

## Bullet ...

* Is a real-time query engine that lets you run queries on very large data streams

* Does not use a **a persistence layer**. This makes it **light-weight, cheap and fast**

* Is a **look-forward** query system. Queries are submitted first and they operate on data that arrive after the query is submitted

* Is **multi-tenant** and can scale independently for more queries and for more data in the first order

* Provides a **UI and Web Service** that are also pluggable for a full end-to-end solution to your querying needs

* Can be implemented on different Stream processing frameworks. Bullet on [Storm](http://storm.apache.org) is currently available

* Is **pluggable**. Any data source that can be read from Storm can be converted into a standard data container letting you query that data. Data is **typed**

* Is used at scale and in production at Yahoo with running 500+ queries simultaneously on 200,000 rps (records per second) and tested up to 2,000,000 rps

## How is this useful

How Bullet is used is largely determined by the data source it consumes. Depending on what kind of data you put Bullet on, the types of queries you run on it and your use-cases will change. As a look-forward query system with no persistence, you will not be able to repeat your queries on the same data. The next time you run your query, it will operate on the different data that arrives after that submission. If this usage pattern is what you need and you are looking for a light-weight system that can tap into your streaming data, then Bullet is for you!

### Example: How Bullet is used at Yahoo

Bullet is used in production internally at Yahoo by having it sit on a subset of raw user engagement events from Yahoo sites and apps. This lets Yahoo developers automatically validate their instrumentation code *end-to-end* in their Continuous Delivery pipelines. Validating instrumentation is critical since it powers pretty much all decisions and products including machine learning, corporate KPIs, analytics, personalization, targeting.

This instance of Bullet also powers other use-cases such as letting analysts validate assumptions about data, product managers verify launches instantly, debug issues and outages, or simply explore and play around with the data.

---

# Quick Start

See [Quick Start](quick-start.md) to set up Bullet on a local Storm topology. We will generate some fake streaming data that you can then query with Bullet.

# Setting up Bullet on your streaming data

To set up Bullet on a real data stream, you need:

1. The backend set up on a Stream processor:
    1. Plug in your source of data. See [Getting your data into Bullet](backend/ingestion.md) for details
    2. Consume your data stream. Currently, we support [Bullet on Storm](backend/setup-storm.md)
2. The [Web Service](ws/setup.md) set up to convey queries and return results back from the backend
3. The optional [UI](ui/setup.md) set up to talk to your Web Service. You can skip the UI if all your access is programmatic

!!! note "Schema in the UI"

    The UI also needs an endpoint that provides your data schema to help with query building. The Web Service you set up provides a simple file based schema endpoint that you can point the UI to if that is sufficient for your needs.

---

# Querying in Bullet

Bullet queries allow you to filter, project and aggregate data. It lets you fetch raw (the individual data records) as well as aggregated data.

See the [UI Usage section](ui/usage.md) for using the UI to build Bullet queries. This is the same UI you will build in the [Quick Start](quick-start.md)

See the [API section](ws/api.md) for building Bullet API queries.

For examples using the API, see [Examples](ws/examples.md). These are actual albeit cleansed queries sourced from the instance at Yahoo.

## Termination conditions

A Bullet query terminates and returns whatever has been collected so far when:

1. A maximum duration is reached. In other words, a query runs for a defined time window
2. A maximum number of records is reached (only applicable for queries that are fetching raw data records and not aggregating).

## Filters

Bullet supports two kinds of filters:

| Filter Type        | Meaning |
| ------------------ | ------- |
| Logical filter     | Allow you to combine filter clauses (Logical or Relational) with logical operations like AND, OR and NOTs |
| Relational filters | Allow you to use comparison operations like equals, not equals, greater than, less than, regex like etc, on fields |

## Projections

Projections allow you to pull out only the fields needed and rename them when you are querying for raw data records.

## Aggregations

Aggregations allow you to perform some operation on the collected records.

The current aggregation types that are supported are:

| Aggregation    | Meaning |
| -------------- | ------- |
| GROUP          | The resulting output would be a record containing the result of an operation for each unique value combination in your specified fields |
| COUNT DISTINCT | Computes the number of distinct elements in the fields. (May be approximate) |
| LIMIT or RAW   | The resulting output would be at most the number specified in size. |

Currently we support ```GROUP``` aggregations on the following operations:

| Operation      | Meaning |
| -------------- | ------- |
| COUNT          | Computes the number of the elements in the group |
| SUM            | Computes the sum of the elements in the group |
| MIN            | Returns the minimum of the elements in the group |
| MAX            | Returns the maximum of the elements in the group |
| AVG            | Computes the average of the elements in the group |

# Results

The Bullet Web Service returns your query result as well as associated metadata information in a structured JSON format. The UI can display the results in different formats.

---

# Approximate computation

It is often intractable to perform aggregations on an unbounded stream of data and still support arbitrary queries. However, it is possible if an exact answer is not required and the approximate answer's error is exactly quantifiable. There are stochastic algorithms and data structures that let us do this. We use [Data Sketches](https://datasketches.github.io/) to perform aggregations such as counting uniques, and will be using Sketches to implement some future aggregations.

Sketches let us be exact in our computation up to configured thresholds and approximate after. The error is very controllable and quantifiable. All Bullet queries that use Sketches return the error bounds with Standard Deviations as part of the results so you can quantify the error exactly. Using Sketches lets us address otherwise hard to solve problems in sub-linear space.

We also use Sketches as a way to control high cardinality grouping (group by a natural key column or related) and rely on the Sketching data structure to drop excess groups. It is up to you setting up Bullet to determine to set Sketch sizes large or small enough for to satisfy the queries that will be performed on that instance of Bullet.

## New query types coming soon

Using Sketches, we have implemented ```COUNT DISTINCT``` and ```GROUP``` and are working on other aggregations including but not limited to:

| Aggregation    | Meaning |
| -------------- | ------- |
| TOP K          | Returns the top K most frequently appearing values in the column |
| DISTRIBUTION   | Computes distributions of the elements in the column. E.g. Find the median value or the 95th percentile of a field or graph the entire distribution as a histogram |

# Architecture

## Backend

![High Level Architecture](img/higharch.png)

The Bullet backend can be split into three main sub-systems:

1. Request Processor - receives queries, adds metadata and sends it to the rest of the system
2. Data Processor - converts the data from an stream and matches it against queries
3. Combiner - combines results for different queries, performs final aggregations and returns results

## Web Service and UI

The rest of the pieces are just the standard other two pieces in a full-stack application:

  * A Web Service that talks to this backend
  * A UI that talks to this Web Service

The [Bullet Web Service](ws/api.md) is built using [Jersey](https://jersey.java.net/) and the [UI](ui/usage.md) is built in [Ember](emberjs.com).

The Web Service can be deployed with your favorite servlet container like [Jetty](http://www.eclipse.org/jetty/). The UI is a client-side application that can be served using [Node.js](http://nodejs.org/)

In the case of Bullet on Storm, the Web Service and UI talk to the backend using [Storm DRPC](http://storm.apache.org/releases/1.0.0/Distributed-RPC.html).

## End-to-End Architecture

![Overall Storm Architecture](img/overallarch.png)

!!! note "Want to know more?"
    In practice, the backend is implemented using the basic components that the Stream processing framework provides. See [Storm Architecture](backend/storm-architecture.md) for details.

# Past Releases and Source

See the [Releases](about/releases.md) section where the various Bullet releases and repository links are collected in one place.
