# Contributing

We welcome all contributions! We also welcome all usage experiences, stories, annoyances and whatever else you want to say. Head on over to our [Contact Us page](contact.md) and let us know!

## Contributor License Agreement (CLA)

Bullet is hosted under the [Yahoo Github Organization](https://github.com/yahoo). In order to contribute to any Yahoo project, you will need to submit a CLA. When you submit a Pull Request to any Bullet repository, a CLABot will ask  you to sign the CLA if you haven't signed one already.

Read the [human-readable summary](https://yahoocla.herokuapp.com/) of the CLA.

## Future plans

Here is a selected list of features we are currently considering/working on. Feel free to [contact us](contact.md) with any ideas/suggestions/PRs for features mentioned here or anything else you think about!

This list is neither comprehensive nor in any particular order.

| Feature             | Components  | Description               | Status        |
|-------------------- | ----------- | ------------------------- | ------------- |
| Incremental updates | BE, WS, UI  | Push results back to users during the query lifetime. Micro-batching, windowing and other features need to be implemented | In Progress |
| Bullet on Spark     | BE          | Implement Bullet on Spark Streaming. Compared with SQL on Spark Streaming which stores data in memory, Bullet will be light-weight | In Progress |
| Security            | WS, UI      | The obvious enterprise security for locking down access to the data and the instance of Bullet. Considering SSL, Kerberos, LDAP etc. Ideally, without a database | Planning |
| In-Memory PubSub    | PubSub      | For users who don't want a PubSub like Kafka, we could add REST based in-memory PubSub layer that runs in the WS. The backend will then communicate directly with the WS | Planning |
| LocalForage         | UI          | Migration the UI to LocalForage to distance ourselves from the relatively small LocalStorage space | [#9](https://github.com/yahoo/bullet-ui/issues/9) |
| Bullet on X         | BE          | With the pub/sub feature, Bullet can be implemented on other Stream Processors like Flink, Kafka Streaming, Samza etc | Open |
| Bullet on Beam      | BE          | Bullet can be implemented on [Apache Beam](https://beam.apache.org) as an alternative to implementing it on various Stream Processors | Open |
| SQL API             | BE, WS      | WS supports an endpoint that converts a SQL-like query into Bullet queries | Open |
| Packaging           | UI, BE, WS  | Github releases and building from source are the only two options for the UI. Docker images or the like for quick setup and to mix and match various pluggable components would be really useful | Open |
| Spring Boot Reactor | WS          | Migrate the Web Service to use Spring Boot reactor instead of servlet containers | Open |
