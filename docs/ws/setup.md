# The Web Service

The Web Service is a Java WAR file that you can deploy on a machine to communicate with the Bullet Backend. For Storm, it talks to the Storm DRPC servers. To set up the Bullet backend topology, see [Storm setup](../backend/setup-storm.md).

There are two main purposes for this layer at this time:

1) It provides an endpoint that can serve a [JSON API schema](http://jsonapi.org/format/) for the Bullet UI. Currently, static schemas from a file are supported.

2) It proxies a JSON Bullet query to Bullet and wraps errors if the backend is unreachable.

!!! note "That's it?"

    The Web Service essentially just wraps Storm DRPC and provides some helpful endpoints. But the Web Service is there to be a point of abstraction for implementing things like security, monitoring, access-control, rate-limiting, different query formats (e.g. SQL Bullet queries) etc, which are planned in the near future.

## Prerequisites

In order for your Web Service to work with Bullet, you should have an instance of the [backend](../backend/setup-storm.md) already set up.

## Installation

You can download the WAR file directly from [JCenter](http://jcenter.bintray.com/com/yahoo/bullet/bullet-service/).

If you need to depend on the source code directly for any reason, you need to add the JCenter repository and get the artifact through your dependency management system. Maven is shown below.

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

You can also add ```<classifier>sources</classifier>```  or ```<classifier>javadoc</classifier>``` if you want the source or javadoc.

## Configuration

You specify how to talk to your Bullet instance and where to find your schema file (optional for if you want to power the [UI](../ui/usage.md) schema with a static file) through a configuration file. See sample at [bullet_defaults.yaml](src/main/resources/bullet_defaults.yaml).

The values in the defaults file are used for any missing properties. You can specify a path to your custom configuration using the property:

```bash
bullet.service.configuration.file=<path to your configuration file>
```

For example, if you are using Jetty as your servlet container,

```bash
java -jar -Dbullet.service.configuration.file=/var/bullet-service/context.properties start.jar
```

!!! note "Spring and context"

    The Web Service uses your passed in configuration properties file to configure its dependency injections using [Spring](http://spring.io/). See [ApplicationContext.xml](https://github.com/yahoo/bullet-service/blob/master/src/main/resources/ApplicationContext.xml) for how this is loaded.

### File based schema

The Web Service can also provide a endpoint that serves your data schema to your UI. You do not necessarily have to use this to serve your schema. The UI can use any JSON API schema specification. But if your schema is fixed or does not change often, it might be simpler for you to use this endpoint to provide the schema for the UI, instead of creating a new one. The Web Service also takes care to provide the right [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS) headers so that your UI can communicate with it.

You can use [sample_columns.json](https://github.com/yahoo/bullet-service/blob/master/src/main/resources/sample_columns.json) as a guideline for what your actual schema file should look like or if you want to create your own Web Service that dynamically serves your schema to the UI if it changes frequently.

## Launch

You need to deploy the WAR file to a servlet container. We recommend [Jetty](http://www.eclipse.org/jetty/).

### Quick start with Jetty

1. Download a [Jetty installation](http://www.eclipse.org/jetty/download.html)
2. Unarchive the installation into a folder
3. Download the Bullet Service WAR from [JCenter](http://jcenter.bintray.com/com/yahoo/bullet/bullet-service/).
4. Place the WAR into your Jetty installation folder's ```webapps``` directory.
5. Create a properties file containing actual values for the settings in the [defaults](https://github.com/yahoo/bullet-service/blob/master/src/main/resources/default.properties). For example, for Bullet on Storm, you will point to your DRPC servers in the properties. If you want to use the file based schema endpoint, you would point to your schema file.
6. Launch Jetty using ```java -jar -Dbullet.service.configuration.file=/path/to/your/properties/file start.jar```, where start.jar is in your Jetty installation folder.

You should tweak and properly install Jetty into a global location with proper logging when you productionize your Web Service.

## Usage

Once the Web Service is up (defaults to port 8080, you can change it with a ```-Djetty.http.port=<PORT>``` setting), you should be able to test to see if it's able to talk to the Bullet backend:

You can HTTP POST a Bullet query to the API with:

```bash
curl -s -H "Content-Type: application/json" -X POST -d '{}' http://localhost:8080/bullet-service/api/drpc
```

You should receive a random record flowing through Bullet instantly (if you left the Raw aggregation micro-batch size at the default of 1 when launching the Bullet backend).

!!! note "Context Path"

    The context path, or "bullet-service" in the URL above is the name of the WAR file in Jetty. If you rename it, you will need to change this.


If you provided a path to a schema file in your configuration file when you [launch](#launch) the Web Service, you can also HTTP GET your schema at ```http://localhost:8080/bullet-service/api/columns```

If you did not, the schema in [sample_columns.json](https://github.com/yahoo/bullet-service/blob/master/src/main/resources/sample_columns.json) is the response. The Web Service converts it to a JSON API response and provides the right headers for CORS.
