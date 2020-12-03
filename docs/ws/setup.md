# The Web Service

The Web Service is a Java JAR file that you can deploy on a machine to communicate with the Bullet Backend. You then plug in a particular Bullet PubSub implementation such as [Kafka PubSub](../pubsub/kafka.md) or [Storm DRPC PubSub](../pubsub/storm-drpc.md). For an example on how to set up a Bullet backend, see the [Storm example setup](../backend/storm-setup.md).

There are three main purposes for this layer at this time:

1) It converts queries and sends them through the PubSub to the backend. It handles responses from the backend for both synchronous and asynchronous queries.

2) It provides an endpoint that can serve a [JSON API schema](http://jsonapi.org/format/) for the Bullet UI. Currently, static schemas from a file are supported.

3) It manages metadata for queries such unique identifiers or storing queries for resilience for Backends that support replaying.


## Prerequisites

In order for your Web Service to work with Bullet, you should have an instance of the Backend such as [Storm](../backend/storm-setup.md) and a PubSub instance such as [Storm DRPC](../pubsub/storm-drpc.md#setup) or [Kafka](../pubsub/kafka.md#setup) already set up. Alternitively you can run the RESTPubSub as part of the web service. See [RESTPubSub](../pubsub/rest.md) for more info.

## Installation

You can download the JAR file directly from [JCenter](http://jcenter.bintray.com/com/yahoo/bullet/bullet-service/). The Web Service is a [Spring Boot](https://projects.spring.io/spring-boot/) application. It executes as a standalone application. Note that prior to version 0.1.1, bullet-service was a WAR file that you deployed onto a servlet container like Jetty. It now embeds a [Apache Tomcat](http://tomcat.apache.org/) servlet container.

If you need to depend on the source code directly (to add new endpoints for your own purposes or to build a WAR file out of the JAR), you need to add the JCenter repository and get the artifact through your dependency management system. Maven is shown below.

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

```xml
<dependency>
  <groupId>com.yahoo.bullet</groupId>
  <artifactId>bullet-service</artifactId>
  <version>${bullet.version}</version>
</dependency>
```

You can also add ```<classifier>sources</classifier>```  or ```<classifier>javadoc</classifier>``` if you want the source or javadoc or ```<classifier>embedded</classifier>``` if you want the full JAR with the embedded web server.

## Configuration

There are a few different modules in the Web Service:

1. **API**: Configure the Web Service, the web server, the names of various endpoints, and other Spring Boot settings. You can also configure certain top-level settings for the various modules below - such as the number of publishers and subscribers to use for the PubSub etc.
2. **PubSub**: Configure what PubSub to use and the various settings for it.
3. **Schema** (Optional): Configure the Schema file (that powers the [UI](../ui/usage.md).
4. **Query** (Optional): Configure the various query defaults for queries coming into the API. You can also point to the schema used by the BQL module to do type-checking and other semantic validation.
5. **Storage** (Optional): Configure what Storage to use, the various settings for it through another configuration file.
6. **Asynchronous Queries** (Optional): Configure the Asynchronous query module which lets you send queries to an API but not wait for the results. The results, when received, are sent through a PubSubResponder interface that you can plug in - such as email or writing to another PubSub etc.
7. **Metrics** (Optional): Configure the Metrics collection system which collects various statistics about the endpoints and sends them through a Publisher interface that you can plug in. You can use this for monitoring status codes and errors.
8. **Status** (Optional): Configure the Status checking system which disables the API if the backend is down or unreachable. It works by sending a simple query through and waiting for results periodically.

### API Configuration

Take a look at the [settings](https://github.com/bullet-db/bullet-service/blob/master/src/main/resources/application.yaml) for a list of the settings that are configured. The Web Service settings start with ```bullet.```. You can configure various WebSocket settings and other API level configuration.

If you provide a custom settings ```application.yaml```, you will **need** to specify the default values in this file since the framework uses your file instead of these defaults. You can also pass in overrides as command-line arguments when launching the server.

#### Spring Boot Configuration

You can also configure various Spring and web server settings here. Take a look at [this page](https://docs.spring.io/spring-boot/docs/current/reference/html/common-application-properties.html) page for the various values you can supply.

### PubSub Configuration

You configure the PubSub by providing a configuration YAML file and setting the ```bullet.pubsub.config``` to its path. In *that* file, you will set these two settings at a minimum:

1. ```bullet.pubsub.class.name``` should be set to the fully qualified package to your PubSub implementation. Example: ```com.yahoo.bullet.kafka.KafkaPubSub``` for the [Kafka PubSub](../pubsub/kafka.md).
2. ```bullet.pubsub.context.name: QUERY_SUBMISSION```. The Web Service requires the PubSub to be in the ```QUERY_SUBMISSION``` context.

You will also specify other parameters that your chosen PubSub requires or can use.

In the top level configuration for the PubSub in ```application.yaml```, you may configure the number of threads for reading and writing the PubSub as well as enabling and configuring the built-in [REST PubSub](../pubsub/rest.md) if you choose to use that.

### Schema Configuration

The Web Service can also provide a endpoint that serves your data schema to your UI. You do not necessarily have to use this to serve your schema. The UI can use any JSON API schema specification. But if your schema is fixed or does not change often, it might be simpler for you to use this endpoint to provide the schema for the UI, instead of creating a new one. The Web Service also takes care to provide the right [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS) headers so that your UI can communicate with it.

You can use [sample_columns.json](https://github.com/bullet-db/bullet-service/blob/master/src/main/resources/sample_columns.json) as a guideline for what your actual schema file should look like or if you want to create your own Web Service that dynamically serves your schema to the UI if it changes frequently.

Once you have your schema file, you can provide it to the Web Service by setting the ```bullet.schema.file``` to the path to your file.


### Query Configuration

You can provide a file containing the various query defaults and maximums by using the `bullet.query.config` setting. This is configured used by the query building module to make sure incoming queries respect various configurations provided here such as default aggregation sizes or minimum window emit intervals etc. You can also point to a schema file (ideally the same one used if you chose to enable the schema module) that the query builder layer can use for advanced checking. See [the defaults](https://github.com/bullet-db/bullet-service/blob/master/src/main/resources/query_defaults.yaml) for more information.

!!! note "Querying and Schema"
    If you provide a schema, the query creation layer in BQL can leverage this for type-checking and advanced semantic validation. This can error out otherwise erroneous queries right at the API layer without having to run a query that returns no results or errors out in the backend.

### Storage Configuration

This module lets you set up a Storage layer to write queries to when submitted. These are cleaned up when the query is terminated and the final result sent back to the API. This is particularly relevant if your Bullet instance is fielding long-running queries that need to be resilient. This coupled with a Backend implementation that can leverage the Storage lets you recreate queries in the Backend in case of component failure or restarts. The Storage layer is also particularly relevant if you're using the asynchronous query module with a PubSubResponder interface that relies on the Storage to do additional metadata lookups.

You can configure and provide a Storage implementation by implementing the [StorageManager interface](https://github.com/bullet-db/bullet-core/blob/master/src/main/java/com/yahoo/bullet/storage/StorageManager.java). Note that you cannot turn off the Storage module in the API but by default, the `NullStorageManager` is used, which does nothing. You can provide a configuration yaml file that supplies your particular settings for your StorageManager by using the `bullet.storage.config` setting. See [the defaults](https://github.com/bullet-db/bullet-service/blob/master/src/main/resources/storage_defaults.yaml) for more details.

!!! note "So you DO have persistence?"

    This is not the same as storing the data. Bullet's philosophy is to avoid storing the incoming data stream that it is field queries on. This layer is meant for storing query related information. When we extend the storage to storing intermediate results in the backend for extra resiliency between windows, the size of the storage should still be well defined for sketch-based aggregations.

### Asynchronous Query Configuration

This module enables the asynchronous query submission endpoint (the `bullet.endpoint.async` setting) that lets you submit queries to it without having to hang around for the results to stream back. Instead you use [the PubSubResponder interface](https://github.com/bullet-db/bullet-core/blob/master/src/main/java/com/yahoo/bullet/pubsub/PubSubResponder.java) to provide an instance that is used to write results that come back for that query. You can use this for *alerting* use-cases where you need to send e-mails on certain alert queries being triggered or if you want your results written to a PubSub that you can consume in a different manner etc.

By default, this module is disabled. However, it is mock configured to use [a standard Bullet PubSubResponder](https://github.com/bullet-db/bullet-core/blob/master/src/main/java/com/yahoo/bullet/pubsub/BulletPubSubResponder.java) that we provide to write the result back to a REST PubSub that is assumed to be running locally. You can change this to write the results to your own PubSub if you desire or plug in something else entirely. You can provide a configuration yaml file that supplies your particular settings for your PubSubResponder by using the `bullet.async.config` setting. See the [defaults](https://github.com/bullet-db/bullet-service/blob/master/src/main/resources/async_defaults.yaml) for more information.

### Metrics Configuration

This module lets you monitor the Web Service for information on what is happening. It tracks the various status codes and publishes them using the [MetricPublisher interface](https://github.com/bullet-db/bullet-core/blob/master/src/main/java/com/yahoo/bullet/common/metrics/MetricPublisher.java) to a place of your choice. By default, the [HTTPMetricPublisher interface](https://github.com/bullet-db/bullet-core/blob/master/src/main/java/com/yahoo/bullet/common/metrics/HTTPMetricEventPublisher.java) is configured, which can post to an URL of your choice.

You can provide a configuration yaml file that supplies your particular settings for your MetricPublisher by using the `bullet.metric.config` setting. See the [defaults](https://github.com/bullet-db/bullet-service/blob/master/src/main/resources/metric_defaults.yaml) for more information.

### Status Configuration

This module periodically sents a *tick* query to the backend to make sure it is functioning properly. You can configure various settings for it here. If enabled, this module can disable the whole API if the backend is unreachable. This can be used if you front multiple Web Service instances talking to different instances of a backend behind a proxy and take down the backends one at a time for upgrades.

## Launch

To launch, you will need your PubSub implementation JAR file and launch the application by providing the path to it. For example, if you only wished to provide the PubSub configuration and you had the Web Service jar and your chosen PubSub (say Kafka) in your current directory, you would run:

```bash
java -Dloader.path=bullet-kafka.jar -jar bullet-service.jar --bullet.pubsub.config=pubsub_settings.yaml  --logging.level.root=INFO
```

This launches the Web Service using Kafka as the PubSub, no custom schema (the default sample columns) and the default values in [settings](https://github.com/bullet-db/bullet-service/blob/master/src/main/resources/application.yaml). It also uses a root logging level of ```INFO```.

You could also tweak the various Bullet Web Service or Spring Boot settings by passing them in to the command above. For instance, you could also provide a path to your schema file using ```--bullet.schema.file=/path/to/schema.json```. You could also have a custom ```application.yaml``` file (you can change the name using ```spring.config.name```) and pass it to the Web Service instead by running:

```bash
java -Dloader.path=bullet-kafka.jar -jar bullet-service.jar --spring.config.location=application.yaml
```

## Usage

Once the Web Service is up, you should be able to test to see if it's able to talk to the Bullet Backend:

You can HTTP POST a Bullet query to the API with:

```bash
curl -s -H "Content-Type: text/plain" -X POST -d '{}' http://localhost:5555/api/bullet/query
```

You should receive a random record flowing through Bullet instantly (if you left the Raw aggregation micro-batch size at the default of 1 when launching the Bullet Backend).

!!! note "Context Path"

    The context path, or "/api/bullet" in the URL above can be changed using the Spring Boot setting ```server.context-path```. You can also change the port (defaults to port 5555) using ```server.port```.

If you provided a path to a schema file in your configuration file when you [launch](#launch) the Web Service, you can also HTTP GET your schema at ```http://localhost:5555/api/bullet/columns```

If you did not, the schema in [sample_fields.json](https://github.com/bullet-db/bullet-service/blob/master/src/main/resources/sample_fields.json) is the response. The Web Service converts it to a JSON API response and provides the right headers for CORS.
