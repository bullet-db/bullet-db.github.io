# REST PubSub

The REST PubSub implementation is included in bullet-core, and can be launched along with the Web Service. If it is enabled the Web Service will expose two additional REST endpoints, one for reading/writing Bullet queries, and one
for reading/writing results.

## How does it work?

When the Web Service receives a query from a user, it will create a PubSubMessage and write the message to the "query" RESTPubSub endpoint. This PubSubMessage will contain not only the query, but also some metadata, including the
appropriate host/port to which the response should be sent (this is done to allow for multiple Web Services running simultaneously). The query is then stored in memory until the backend does a GET from this endpoint, at which
time the query will be served to the backend, and dropped from the queue in memory.

Once the backed has generated the results of the query, it will wrap those results in PubSubMessage. The backend extracts the URL to send the results to from the metadata and writes the results PubSubMessage to the
"results" REST endpoint with a POST. This result will then be stored in memory until the Web Service does a GET to that endpoint, at which time the Web Service will have the results of the query to send back to the user.

## Setup

To enable the RESTPubSub and expose the two additional necessary REST endpoints, you must enable the setting:

```yaml
bullet.pubsub.builtin.rest.enabled: true
```

...in the Web Service Application.yaml file. This can also be done from the command line when launching the Web Service jar file by adding the command-line option:

```bash
--bullet.pubsub.builtin.rest.enabled=true
```

This will enable the two necessary REST endpoints, the paths for which can be configured in the Application.yaml file with the settings:

```yaml
bullet.pubsub.builtin.rest.query.path: /pubsub/query
bullet.pubsub.builtin.rest.result.path: /pubsub/result
```

### Plug into the Backend

Configure the backend to use the REST PubSub:

```yaml
bullet.pubsub.context.name: "QUERY_PROCESSING"
bullet.pubsub.class.name: "com.yahoo.bullet.kafka.KafkaPubSub"

bullet.pubsub.rest.connect.timeout.ms: 5000
bullet.pubsub.rest.subscriber.max.uncommitted.messages: 100
bullet.pubsub.rest.result.subscriber.min.wait.ms: 10
bullet.pubsub.rest.query.subscriber.min.wait.ms: 10
bullet.pubsub.rest.query.urls:
    - "http://webServiceHostNameA:9901/api/bullet/pubsub/query"
    - "http://webServiceHostNameB:9902/api/bullet/pubsub/query"
```

* __bullet.pubsub.context.name: "QUERY_PROCESSING"__ - tells the PubSub that it is running in the backend
* __bullet.pubsub.class.name: "com.yahoo.bullet.kafka.KafkaPubSub"__ - tells Bullet to use this class for it's PubSub
* __bullet.pubsub.rest.connect.timeout.ms: 5000__ - sets the HTTP connect timeout to a half second
* __bullet.pubsub.rest.subscriber.max.uncommitted.messages: 100__ - this is the maxiumum number of uncommitted messages allowed before blocking
* __bullet.pubsub.rest.query.subscriber.min.wait.ms: 10__ - this setting is used to avoid making an http request too rapidly and overloading the http endpoint. It will force the backend to poll the query endpoint at most once every 10ms.
* __bullet.pubsub.rest.query.urls__ - this should be a list of all the query rest enpoint URLs. If you are only running one Web Service this will only contain one url (the url of your Web Service followed by the full path of the query endpoint).

### Plug into the Web Service

Configure the Web Service to use the REST PubSub:

```yaml
bullet.pubsub.context.name: "QUERY_SUBMISSION"
bullet.pubsub.class.name: "com.yahoo.bullet.kafka.KafkaPubSub"

bullet.pubsub.rest.connect.timeout.ms: 5000
bullet.pubsub.rest.subscriber.max.uncommitted.messages: 100
bullet.pubsub.rest.result.subscriber.min.wait.ms: 10
bullet.pubsub.rest.query.subscriber.min.wait.ms: 10
bullet.pubsub.rest.result.url: "http://localhost:9901/api/bullet/pubsub/result"
bullet.pubsub.rest.query.urls:
    - "http://localhost:9901/api/bullet/pubsub/query"
```

* __bullet.pubsub.context.name: "QUERY_SUBMISSION"__ - tells the PubSub that it is running in the Web Service
* __bullet.pubsub.class.name: "com.yahoo.bullet.kafka.KafkaPubSub"__ - tells Bullet to use this class for it's PubSub
* __bullet.pubsub.rest.connect.timeout.ms: 5000__ - sets the HTTP connect timeout to a half second
* __bullet.pubsub.rest.subscriber.max.uncommitted.messages: 100__ - this is the maxiumum number of uncommitted messages allowed before blocking
* __bullet.pubsub.rest.query.subscriber.min.wait.ms: 10__ - this setting is used to avoid making an http request too rapidly and overloading the http endpoint. It will force the backend to poll the query endpoint at most once every 10ms.
* __bullet.pubsub.rest.result.url: "http://localhost:9901/api/bullet/pubsub/result"__ - this is the endpoint from which the WebService should read results - it should generally be the hostname of that machine the Web Service is running on (or "localhost").
* __bullet.pubsub.rest.query.urls__ - in the Web Service this setting should contain __exactly one__ url - the url to which queries should be written  - it should generally be the hostname of that machine the Web Service is running on (or "localhost").

