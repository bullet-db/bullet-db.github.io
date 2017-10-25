# Contributing

We welcome all contributions! We also welcome all usage experiences, stories, annoyances and whatever else you want to say. Head on over to our [Contact Us page](contact.md) and let us know!

## Contributor License Agreement (CLA)

Bullet is hosted under the [Yahoo Github Organization](https://github.com/yahoo). In order to contribute to any Yahoo project, you will need to submit a CLA. When you submit a Pull Request to any Bullet repository, a CLABot will ask  you to sign the CLA if you haven't signed one already.

Read the [human-readable summary](https://yahoocla.herokuapp.com/) of the CLA.

## Future plans

Here is some selected list of features we are currently considering/working on. Feel free to [contact us](contact.md) with any ideas/suggestions/PRs for features mentioned here or anything else you think about!

This list is neither comprehensive nor in any particular order.

| Feature             | Components  | Description               | Status        |
|-------------------- | ----------- | ------------------------- | ------------- |
| Incremental updates | BE, WS, UI  | Push results back to users during the query lifetime. Micro-batching, windowing and other features come into play | In Progress |
| Bullet on Spark     | BE          | Implement Bullet on Spark Streaming. Compared with SQL on Spark Streaming which stores data in memory, Bullet will be light-weight | In Progress |
| Security            | WS, UI      | The obvious enterprise security for locking down access to the data and the instance of Bullet. Considering SSL, Kerberos, LDAP etc. | Planning |
| Bullet on X         | BE          | With the pub/sub feature, Bullet can be implemented on other Stream Processors like Flink, Kafka Streaming, Samza etc | Open |
| SQL API             | BE, WS      | WS supports an endpoint that converts a SQL-like query into Bullet queries | Open |
| LocalForage         | UI          | Migration to LocalForage to distance ourselves from the relatively small LocalStorage space | [#9](https://github.com/yahoo/bullet-ui/issues/9) |
| Spring Boot Reactor | WS          | Migrate the Web Service to use Spring Boot reactor instead of servlet containers | Open |
| UI Packaging        | UI          | Github releases and building from source are the only two options. Docker or something similar may be more apt | Open |
