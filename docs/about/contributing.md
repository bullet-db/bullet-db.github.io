# Contributing

We welcome all contributions! We also welcome all usage experiences, stories, annoyances and whatever else you want to say. Head on over to our [Contact](contact.md) and let us know!

## Contributor License Agreement (CLA)

Bullet is hosted under the [Yahoo Github Organization](https://github.com/yahoo). In order to contribute to any Yahoo project, you will need to submit a CLA. When you submit a Pull Request to any Bullet repository, a CLABot will ask  you to sign the CLA if you haven't signed one already.

## Future plans

Here is a list of features we are currently considering/working on. If the Status column is empty, we are still discussing how to approach/break them. They will be updated as they are solidified. Feel free to [contact us](contact.md) with any ideas/suggestions/PRs! 

This list is neither comprehensive nor in any particular order.

| Feature            | Components  | Description               | Status        |
|------------------- | ----------- | ------------------------- | ------------- |
| TOP K              | UI, BE      | A TOP K implementation using DataSketches: FrequentItems | In progress |
| DISTRIBUTION       | UI, BE      | A query to get the distribution/quantiles of a numeric field using DataSketches: Quantiles | In progress |
| Pub-Sub Queue      | BE, WS, UI  | WS and BE talk through the pub/sub. Bullet Storm uses Storm DRPC for this, which is strictly request-response. This will let us work on other Stream Processors and support incremental updates through WebSockets or SSEs | |
| Incremental updates| BE, WS, UI  | Push results back to users as soon as they arrive. Monoidal operations implies additive, so progressive results can be streamed back. Micro-batching and other features come into play | |
| SQL API            | BE, WS      | WS supports an endpoint that converts a SQL-like query into Bullet queries | |
| LocalForage        | UI          | Migration to LocalForage to distance ourselves from the relatively small LocalStorage space | [#9](https://github.com/yahoo/bullet-ui/issues/9) |
| UI Packaging       | UI          | Github releases and building from source are the only two options. Docker or something similar may be more apt | |
| Simple Settings    | UI, WS      | There are several settings in the UI and WS that are directly tied to the BE. They should be configurable and optimally configurable from one location | |
