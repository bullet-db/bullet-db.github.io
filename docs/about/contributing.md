# Contributing

We welcome all contributions! We also welcome all usage experiences, stories, annoyances and whatever else you want to say. Head on over to our [Contact Us page](contact.md) and let us know!

## Contributor License Agreement (CLA)

Bullet is hosted under the [Yahoo Github Organization](https://github.com/yahoo). In order to contribute to any Yahoo project, you will need to submit a CLA. When you submit a Pull Request to any Bullet repository, a CLABot will ask  you to sign the CLA if you haven't signed one already.

## Future plans

Here is a list of features we are currently considering/working on. Feel free to [contact us](contact.md) with any ideas/suggestions/PRs for features mentioned here or anything else you think about!

This list is neither comprehensive nor in any particular order and lists some high level directions.

| Feature             | Components  | Description               | Status        |
|-------------------- | ----------- | ------------------------- | ------------- |
| PubSub              | BE, WS, UI  | WS and BE talk through the PubSub. Bullet Storm uses Storm DRPC for this (strictly request-response) Using a pub/sub queue will let us implement Bullet on other Stream Processors, support incremental updates through WebSockets and more! | In Progress [#1](https://github.com/yahoo/bullet-core/pull/1) |
| Incremental updates | BE, WS, UI  | Push results back to users as soon as they arrive. Our aggregations are additive, so progressive results can be streamed back. Micro-batching and other features come into play | In Progress |
| Security            | WS, UI      | The obvious enterprise security for locking down access to the data and the instance of Bullet. Considering SSL, Kerberos, LDAP etc. | Planning |
| Bullet on X         | BE          | With the pub/sub feature, Bullet can be implemented on other Stream Processors like Spark Streaming, Flink, Kafka Streaming, Samza etc | Open |
| SQL API             | BE, WS      | WS supports an endpoint that converts a SQL-like query into Bullet queries | Open |
| LocalForage         | UI          | Migration to LocalForage to distance ourselves from the relatively small LocalStorage space | [#9](https://github.com/yahoo/bullet-ui/issues/9) |
| UI Packaging        | UI          | Github releases and building from source are the only two options. Docker or something similar may be more apt | Open |
