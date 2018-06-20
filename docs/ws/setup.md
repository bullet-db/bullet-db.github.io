# The Web Service

The Web Service is a Java JAR file that you can deploy on a machine to communicate with the Bullet Backend. You then plug in a particular Bullet PubSub implementation such as [Kafka PubSub](../pubsub/kafka.md) or [Storm DRPC PubSub](../pubsub/storm-drpc.md). For an example on how to set up a Bullet backend, see the [Storm example setup](../backend/storm-setup.md).

There are two main purposes for this layer at this time:

1) It provides an endpoint that can serve a [JSON API schema](http://jsonapi.org/format/) for the Bullet UI. Currently, static schemas from a file are supported.

2) It generates unique identifiers and other metadata for a JSON Bullet query before sending the query to the Bullet backend. It wraps errors if the backend is unreachable.


!!! note "That's it?"

    The Web Service essentially just wraps the PubSub layer and provides some helpful endpoints. When incremental updates drop, it will translate a PubSub's streaming responses back into incremental results for the user. It is also there to be a point of abstraction for implementing things like security, monitoring, access-control, rate-limiting, sharding, different query formats (e.g. SQL Bullet queries) etc, which are planned in the near future.

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

There are two levels of configuration:

1. You can configure the Web Service, the web server and other Spring Boot settings through a configuration file (or through the command line when launching). By default, this file is called ```application.yaml```. This is where settings like where to find your schema file (optional for if you want to power the [UI](../ui/usage.md) schema with a static file) or how many publishers and subscribers to use for your PubSub etc.
2. You can configure what PubSub to use, the various settings for it through another configuration file. The location for this file is provided in the Web Service configuration step above.

### Web Service Configuration

Take a look at the [settings](https://github.com/yahoo/bullet-service/blob/master/src/main/resources/application.yaml) for a list of the settings that are configured. The Web Service settings start with ```bullet.```.

If you provide a custom settings ```application.yaml```, you will **need** to specify the default values in this file since the framework uses your file instead of these defaults.

#### File based schema

The Web Service can also provide a endpoint that serves your data schema to your UI. You do not necessarily have to use this to serve your schema. The UI can use any JSON API schema specification. But if your schema is fixed or does not change often, it might be simpler for you to use this endpoint to provide the schema for the UI, instead of creating a new one. The Web Service also takes care to provide the right [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS) headers so that your UI can communicate with it.

You can use [sample_columns.json](https://github.com/yahoo/bullet-service/blob/master/src/main/resources/sample_columns.json) as a guideline for what your actual schema file should look like or if you want to create your own Web Service that dynamically serves your schema to the UI if it changes frequently.

Once you have your schema file, you can provide it to the Web Service by setting the ```bullet.schema.file``` to the path to your file.

#### Spring Boot Configuration

You can also configure various Spring and web server here. Take a look at [this page](https://docs.spring.io/spring-boot/docs/current/reference/html/common-application-properties.html) page for the various values you can supply.

### PubSub Configuration

You configure the PubSub by providing a configuration YAML file and setting the ```bullet.pubsub.config``` to its path. In *that* file, you will set these two settings at a minimum:

1. ```bullet.pubsub.class.name``` should be set to the fully qualified package to your PubSub implementation. Example: ```com.yahoo.bullet.kafka.KafkaPubSub``` for the [Kafka PubSub](../pubsub/kafka.md).
2. ```bullet.pubsub.context.name: QUERY_SUBMISSION```. The Web Service requires the PubSub to be in the ```QUERY_SUBMISSION``` context.

You will also specify other parameters that your chosen PubSub requires or can use.

## Launch

To launch, you will need your PubSub implementation JAR file and launch the application by providing the path to it. For example, if you only wished to provide the PubSub configuration and you had the Web Service jar and your chosen PubSub (say Kafka) in your current directory, you would run:

```bash
java -Dloader.path=bullet-kafka.jar -jar bullet-service.jar --bullet.pubsub.config=pubsub_settings.yaml  --logging.level.root=INFO
```

This launches the Web Service using Kafka as the PubSub, no custom schema (the default sample columns) and the default values in [settings](https://github.com/yahoo/bullet-service/blob/master/src/main/resources/application.yaml). It also uses a root logging level of ```INFO```.

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

If you did not, the schema in [sample_columns.json](https://github.com/yahoo/bullet-service/blob/master/src/main/resources/sample_columns.json) is the response. The Web Service converts it to a JSON API response and provides the right headers for CORS.
