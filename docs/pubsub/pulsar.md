# Pulsar PubSub

The Pulsar implementation of the Bullet PubSub uses [Apache Pulsar](https://pulsar.apache.org) as the backing PubSub messaging queue and can be used with any Backend and Web Service.

## How does it work?

Bullet Pulsar requires at least one Pulsar topic for queries and at least one Pulsar topic for results. On the Web Service, the PubSub is used to create publishers and subscribers that write queries and read results. Similarly, on the Backend, the PubSub is used to create publishers and subscribers that read queries and write results. Both queries and results are sent as [PubSubMessages](architecture.md#messages) over the Pulsar topics.

With the Pulsar implementation, it is also possible to shard the Web Service by having each Web Service specify a different topic to read results from. Additionally, you may specify a different topic for each Web Service to write queries to, but this is optional as there is only one Backend reading queries.

## Setup

Before using Bullet Pulsar, you will need to first set up a Pulsar cluster. To do so, follow the [instructions here](https://pulsar.apache.org/docs/en/standalone/).

!!!note

    For a quick setup, Pulsar topics can be automatically created

### Plug into the Backend

Depending on how your Backend is built, you will need to either add Bullet Pulsar to your classpath or include it in your build tool. Get the artifact on our [releases page](../releases.md#bullet-pulsar).

Note, if you're adding Bullet Pulsar to the classpath instead of building a fat jar, you will need to get the jar with the classifier ```fat``` since you will need Bullet Pulsar with all of its dependencies.

Configure the Backend to use the Pulsar PubSub:

```yaml
bullet.pubsub.context.name: "QUERY_PROCESSING"
bullet.pubsub.class.name: "com.yahoo.bullet.pulsar.PulsarPubSub"
bullet.pubsub.pulsar.client.serviceUrl: "pulsar://your-service-url"
bullet.pubsub.pulsar.consumer.subscriptionName: "your-subscription-name"\
bullet.pubsub.pulsar.response.topic.names: ["persistent://sample/ns1/your-query-topic"]
```

You will also need to configure the Pulsar Client, Producer, and Consumer properties used by the PubSub Publishers and Subscribers.

See the [default configuration file](https://github.com/bullet-db/bullet-pulsar/blob/master/src/main/resources/bullet_pulsar_defaults.yaml) for complete configuration details.

### Plug into the Web Service

You will need to head over to our [releases page](../releases.md#bullet-pulsar) and get the JAR artifact with the ```fat``` classifier. You can download the artifact for the 1.1.0 release [directly from Maven Central](https://repo1.maven.org/maven2/com/yahoo/bullet/bullet-pulsar/1.1.0/)).

You should then plug in this JAR to your Web Service following the instructions [here](../ws/setup.md#launch).

For configuration, you should [follow the steps here](../ws/setup.md#pubsub-configuration) to create and provide a YAML file to the Web Service. Remember to set the context to ```QUERY_SUBMISSION```.

```yaml
bullet.pubsub.context.name: "QUERY_SUBMISSION"
bullet.pubsub.class.name: "com.yahoo.bullet.pulsar.PulsarPubSub"
bullet.pubsub.pulsar.client.serviceUrl: "pulsar://your-service-url"
bullet.pubsub.pulsar.consumer.subscriptionName: "your-subscription-name"
bullet.pubsub.pulsar.request.topic.name: "persistent://sample/ns1/your-query-topic"
bullet.pubsub.pulsar.response.topic.name: "persistent://sample/ns1/your-response-topic"
```

As with the Backend, you will need to configure the Pulsar Client, Producer, and Consumer properties used by the PubSub Publishers and Subscribers.

See the [default configuration file](https://github.com/bullet-db/bullet-pulsar/blob/master/src/main/resources/bullet_pulsar_defaults.yaml) for complete configuration details.

Remember that your Subscribers in the Backend are reading what the Producers in your Web Service are producing and vice-versa, so make sure to match up topics and settings accordingly.

## Passthrough configuration

You can configure the Pulsar Client, Producer, or Consumer properties for the PubSub Publishers and Subscribers by prefixing them with either `bullet.pubsub.pulsar.client.`, `bullet.pubsub.pulsar.producer.`, or `bullet.pubsub.pulsar.consumer.` respectively. The PubSub configuration sets a few of its own defaults but otherwise uses the default Pulsar settings.

See the [default configuration file](https://github.com/bullet-db/bullet-pulsar/blob/master/src/main/resources/bullet_pulsar_defaults.yaml) for complete configuration details with their defaults.

## Security

Pulsar supports Athenz Authentication and TLS, and Bullet Pulsar can be configured to use these. For complete details, see the [Pulsar documentation](http://pulsar.apache.org/docs/en/security-overview/).

```yaml
# Note, these properties are not prefixed by "bullet.pubsub.pulsar.client."
bullet.pubsub.pulsar.auth.enable: true
bullet.pubsub.pulsar.auth.plugin.class.name: "org.apache.pulsar.client.impl.auth.AuthenticationAthenz"
bullet.pubsub.pulsar.auth.params.string: '{"tenantDomain":"your_domain","tenantService":"your_app","providerDomain":"pulsar","privateKey":"file:///path/to/private.pem","keyId":"v1"}'
```

```yaml
# Enable TLS
bullet.pubsub.pulsar.client.useTls: true
bullet.pubsub.pulsar.client.tlsAllowInsecureConnection: false
bullet.pubsub.pulsar.client.tlsTrustCertsFilePath: "/path/to/cacert.pem"
```
