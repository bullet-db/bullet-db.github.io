# The UI Layer

The Bullet UI lets you easily create and work with Bullet queries and results for your custom data. It stores all created queries, results and other metadata in the local browser storage or [IndexedDB](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API).

!!! note "Really!? Browser Storage only!?"

    We're serious about the no persistence thing with Bullet! And while we're at it, we are also not interested in supporting old browsers. Joking aside though, we wanted to keep Bullet as light and simple as possible to start with. We can look into extending support from the server-side by adding a database or the like if needed. In practice, we have found that this isn't as important as it initially seems.

## Prerequisites

In order for your UI to work with Bullet, you should have:

  * An instance of the [backend](../backend/storm-setup.md) set up
  * An instance of the [Web Service](../ws/setup.md) set up
  * You should also have a Web Service serving your schema (either by using the [file based serving](../ws/setup.md#file-based-schema) from the Web Service or your own somewhere else)

## Installation

We are considering various packaging options at the moment like Docker etc. In the meantime, the following two options are available:

### GitHub Releases

* Head to the [Releases page](../releases.md#bullet-ui) and grab the latest release
* Download the bullet-ui-vX.X.X.tar.gz archive
* Unarchive it into your web server where you wish to run the UI.
* Install [Node](https://nodejs.org/) (recommend using [nvm](https://github.com/creationix/nvm) to manage Node versions) on the web server

### Build from source

* Install [Node](https://nodejs.org/) (recommend using [nvm](https://github.com/creationix/nvm) to manage Node versions).
* Install [Yarn](https://yarnpkg.com/lang/en/). Use NPM to install it with ```npm install -g yarn```
* Install [Ember](http://emberjs.com/). ```sudo npm install -g ember-cli``` (sudo required only if not using nvm)
* git clone git@github.com:bullet-db/bullet-ui.git
* cd bullet-ui
* `yarn`
* `ember build --environment production`

The entire application with all its assets and dependencies are compiled and placed into dist/. You could point a web server directly at this folder but you will **only** be able to use the default configuration (see [below](#configuration)).

## Running

There is a Node.js server endpoint defined at [server/index.js](server/index.js) to serve the UI. This dynamically injects the settings (see configuration [below](#configuration)) into the served UI based on the environment variable NODE_ENV. You should not need to worry about if you only have one environment.

The entry-point for the UI is the [Express](http://expressjs.com/) endpoint defined as the main in package.json that simply adds the server/index.js as a middleware.

Regardless of which [installation](#installation) option you chose, you need the following folder structure in order to run the UI:

```
dist/*
config/env-settings.json
server/index.js
express-server.js
```

You can use node to launch the UI from the top-level of the folder structure above.

To launch the UI with the default settings (without specifying proper API endpoints you will not be able to create or run a query):

```bash
PORT=8800 node express-server.js
```

To launch with custom settings:

```bash
NODE_ENV=<your_property_name_from_env-settings.json> PORT=8800 node express-server.js
```
Visit localhost:8800 to see your UI that should be configured with the right settings.

## Configuration

The configuration for the UI lets you have different instances of Bullet for different environments (e.g. CI, Staging, Production). These settings can be found in [env-settings.json](https://github.com/bullet-db/bullet-ui/blob/master/config/env-settings.json).

|    Setting                |     Meaning      |
| ------------------------- | ---------------- |
| queryHost                 | The end point (port included) of your Web Service machine that is talking to the Bullet backend |
| queryNamespace            | Any qualifiers you have after your host and port on your Web Service running on your ```queryHost``` |
| queryPath                 | The path fragment after the ```queryNamespace``` on your Web Service running on your ```queryHost``` for the WebSocket endpoint |
| validationPath            | The path fragment after the ```queryNamespace``` on your Web Service running on your ```queryHost``` for the Query Validation endpoint |
| queryStompRequestChannel  | The fragment after this is the Stomp Request channel as configured in your Web Service for the WebSocket endpoint |
| queryStompResponseChannel | The fragment after this is the Stomp Response channel as configured in your Web Service for the WebSocket endpoint |
| schemaHost                | The end point (port included) of your Web Service machine that is serving your schema in the JSON API format (see [Web Service setup](../ws/setup.md) for details.)|
| schemaNamespace           | The path fragment on your schema Web Service running on the ```schemaHost```. There is no ```schemaPath``` because it **must** be ```columns``` in order for the UI to be able fetch the column resource (the fields in your schema).|
| modelVersion              | This is used an indicator to apply changes to the stored queries, results etc. It is monotonically increasing. On startup, changes specified in ```migrations``` will be applied if the old modelVersion is not present or is < than this number. This is generally incremented by the UI once backwards-incompatible changes are made. |
| migrations                | is an object that currently supports one key: ```deletions``` of type string. The value can be set to either ```result``` or ```query```. The former wipes all existing results. The latter wipes everything. See ```modelVersion``` above. |
| helpLinks                 | Is a list of objects, where each object is a help link. These links populate the "Help" drop-down on the UI's top navbar. You can add links to explain your data for example |
| defaultQuery              | Can either be a [API Query](../ws/api.md) or a URL from which one could be fetched dynamically. The UI makes this the query created on every newly created Query. You could use this as a way to have user specific (for example, cookie based) filters created for your users or customize an aggregation when they create a new query in the UI. Note that Builder Query do not support all API queries yet but whatever query you specify here (as long as it's a valid query) will be supported in the BQL query page in the UI. If it is not possible to convert your query into a Builder query, a default one will be used instead. |
| bugLink                   | Is a URL that by default points to the issues page for the UI GitHub repository. You can change it to point to your own custom JIRA queue or something else |
| defaultValues             | Is an object that lets you configures defaults for various query parameters and lets you tie your custom backend settings to the UI |

These are the properties in the ```defaultValues``` object. The Validated column denotes if the value is used when validating a query for correctness and the In Help column denotes if the value is displayed in the popover help messages in the UI.

|         Default Values                  | Validated | In Help |     Meaning      |
| --------------------------------------- | --------- | ------- | ---------------- |
| aggregationMaxSize                      | Yes       | Yes     | The size used when doing a Count Distinct, Distinct, Group By, or Distribution query. Set this to your max aggregations size in your backend configuration |
| rawMaxSize                              | Yes       | Yes     | The maximum size for a Raw query. Set this to your max raw aggregation size in your backend configuration |
| durationMaxSecs                         | Yes       | Yes     | The maximum duration for a query. Set this to the seconds version of the milliseconds max duration in your backend configuration |
| distributionNumberOfPoints              | Yes       | No      | The default value filled in for the Number of Points field for all Distribution aggregations |
| distributionQuantilePoints              | No        | No      | The default value filled in for the Points field for Quantile Distribution aggregations |
| distributionQuantileStart               | No        | No      | The default value filled in for the Start field for Quantile Distribution aggregations |
| distributionQuantileEnd                 | No        | No      | The default value filled in for the End field for Quantile Distribution aggregations |
| distributionQuantileIncrement           | No        | No      | The default value filled in for the Increment field for Quantile Distribution aggregations |
| windowEmitFrequencyMinSecs              | Yes       | No      | The minimum time interval at which a time based window can be returned in seconds. Set this to the minimum window emit frequency from your backend configuration |
| everyForRecordBasedWindow               | No        | No      | The default value for the number of records in a window for a record based window |
| everyForTimeBasedWindow                 | No        | No      | The default value for the number of records in a window for a time based window in milliseconds |
| sketches.countDistinctMaxEntries        | No        | Yes     | The maximum entries configured for your Count Distinct sketch in your backend configuration |
| sketches.groupByMaxEntries              | No        | Yes     | The maximum entries configured for your Group sketch in your backend configuration |
| sketches.distributionMaxEntries         | No        | Yes     | The maximum entries configured for your Distribution sketch in your backend configuration |
| sketches.distributionMaxNumberOfPoints  | Yes       | Yes     | The maximum number of points allowed for Distribution aggregations in your backend configuration |
| sketches.topKMaxEntries                 | No        | Yes     | The maximum entries configured for your Top K sketch in your backend configuration |
| sketches.topKErrorType                  | No        | Yes     | The ErrorType used for your Top K sketch in your backend configuration. You should set this to the full String rather than ```NFN``` or ```NFP``` |
| metadataKeyMapping.querySection         | No        | Yes     | The name of the Metadata key for the Query Concept in your backend configuration |
| metadataKeyMapping.windowSection        | No        | Yes     | The name of the Metadata key for the Window Concept in your backend configuration |
| metadataKeyMapping.innerQuerySection    | No        | No      | The name of the Metadata key for the Inner Query (if any for your query) Concept in your backend configuration |
| metadataKeyMapping.sketchSection        | No        | Yes     | The name of the Metadata key for the Sketches Concept in your backend configuration |
| metadataKeyMapping.theta                | No        | Yes     | The name of the Metadata key for the Theta Concept in your backend configuration |
| metadataKeyMapping.uniquesEstimate      | No        | Yes     | The name of the Metadata key for the Uniques Estimate Concept in your backend configuration |
| metadataKeyMapping.queryCreationTime    | No        | Yes     | The name of the Metadata key for the Query Creation Time Concept in your backend configuration |
| metadataKeyMapping.queryTerminationTime | No        | Yes     | The name of the Metadata key for the Query Termination Time Concept in your backend configuration |
| metadataKeyMapping.estimatedResult      | No        | Yes     | The name of the Metadata key for the Estimated Result Concept in your backend configuration |
| metadataKeyMapping.standardDeviations   | No        | Yes     | The name of the Metadata key for the Standard Deviations Concept in your backend configuration |
| metadataKeyMapping.normalizedRankError  | No        | Yes     | The name of the Metadata key for the Normalized Rank Error Concept in your backend configuration |
| metadataKeyMapping.maximumCountError    | No        | Yes     | The name of the Metadata key for the Maximum Count Error Concept in your backend configuration |
| metadataKeyMapping.itemsSeen            | No        | Yes     | The name of the Metadata key for the Items Seen Concept in your backend configuration |
| metadataKeyMapping.minimumValue         | No        | Yes     | The name of the Metadata key for the Minimum Value Concept in your backend configuration |
| metadataKeyMapping.maximumValue         | No        | Yes     | The name of the Metadata key for the Maximum Value Concept in your backend configuration |

You can specify values for each property above in the ```env-settings.json``` file. These will be used when running a custom instance of the UI (see [above](#Running)).

The ```default``` property in the ```env-settings.json``` that loads default settings for the UI that can be selectively overridden based on which environment you are running on. All settings explained above have default values
that are the same as the [default backend settings](https://github.com/bullet-db/bullet-storm/blob/master/src/main/resources/bullet_defaults.yaml).

```json
{
  "default": {
    "queryHost": "http://localhost:5555",
    "queryNamespace": "api/bullet/queries",
    "queryPath": "ws-query",
    "validationPath": "validate-query",
    "queryStompRequestChannel": "/server/request",
    "queryStompResponseChannel": "/client/response",
    "schemaHost": "http://localhost:5555",
    "schemaNamespace": "api/bullet",
    "helpLinks": [
      {
        "name": "Tutorials",
        "link": "https://bullet-db.github.io/ui/usage"
      }
    ],
    "bugLink": "https://github.com/bullet-db/bullet-ui/issues",
    "modelVersion": 4,
    "migrations": {
      "deletions": "query"
    },
    "defaultQuery": "SELECT COUNT(*) FROM STREAM(60000, TIME) WINDOWING TUMBLING(2000, TIME);",
    "defaultValues": {
      "aggregationMaxSize": 500,
      "rawMaxSize": 100,
      "durationMaxSecs": 9007199254740,
      "distributionNumberOfPoints": 11,
      "distributionQuantilePoints": "0, 0.25, 0.5, 0.75, 0.9, 1",
      "distributionQuantileStart": 0,
      "distributionQuantileEnd": 1,
      "distributionQuantileIncrement": 0.1,
      "windowEmitFrequencyMinSecs": 1,
      "everyForRecordBasedWindow": 1,
      "everyForTimeBasedWindow": 2000,
      "sketches": {
        "countDistinctMaxEntries": 16384,
        "groupByMaxEntries": 512,
        "distributionMaxEntries": 1024,
        "distributionMaxNumberOfPoints": 100,
        "topKMaxEntries": 1024,
        "topKErrorType": "No False Negatives"
      },
      "metadataKeyMapping": {
        "querySection": "Query",
        "windowSection": "Window",
        "sketchSection": "Sketch",
        "theta": "Theta",
        "uniquesEstimate": "Uniques Estimate",
        "queryCreationTime": "Receive Time",
        "queryTerminationTime": "Finish Time",
        "estimatedResult": "Was Estimated",
        "standardDeviations": "Standard Deviations",
        "normalizedRankError": "Normalized Rank Error",
        "maximumCountError": "Maximum Count Error",
        "itemsSeen": "Items Seen",
        "minimumValue": "Minimum Value",
        "maximumValue": "Maximum Value",
        "windowNumber": "Number",
        "windowSize": "Size",
        "windowEmitTime": "Emit Time",
        "expectedEmitTime": "Expected Emit Time"
      }
    }
  }
}
```

You can add more properties for each environment you have the UI running on and *override* the properties in the ```default``` object. See [below](#example) for an example.

!!! note "CORS"

    All your Web Service endpoints must support CORS (return the right headers) in order for the UI to be able to communicate with it. The Bullet Web Service already does this for the Query and Schema endpoints.

### Example

To cement all this, if you wanted an instance of the UI in your CI environment, you could add another property to the ```env-settings.json``` file.

```json
{
    "ci": {
        "queryHost": "http://bullet-ws.dev.domain.com:4080",
        "schemaHost": "http://bullet-ws.dev.domain.com:4080",
        "helpLinks": [
          {
            "name": "Custom Documentation",
            "link": "http://data.docs.domain.com"
          }
        ],
        "defaultValues" : {
            "durationMaxSecs": 300,
            "sketches": {
                "countDistinctMaxEntries": 32768,
                "distributionMaxNumberOfPoints": 50
            }
        },
        "defaultQuery": "http://bullet-ws.dev.domain.com:4080/custom-endpoint/api/defaultQuery"
    }
}
```

Your UI on your CI environment will:

  * Talk using Websockets to ```http://bullet-ws.dev.domain.com:4080/api/bullet/ws-query``` for UI created Bullet queries
  * GET the schema from ```http://bullet-ws.dev.domain.com:4080/api/bullet/columns```
  * Validate queries in the BQL page with ```http://bullet-ws.dev.domain.com:4080/api/bullet/validate-query```
  * Populate an additional link on the Help drop-down pointing to ```http://data.docs.domain.com```
  * Allow queries to run as long as 300 seconds
  * Use 32768 in the help menu for the max number of unique elements that can be counted exactly
  * Allow only 50 points to be generated for Distribution queries
  * GET and cache a default query from ```http://bullet-ws.dev.domain.com:4080/custom-endpoint/api/defaultQuery```

You would make express use these settings by running

```bash
NODE_ENV=ci PORT=8800 node express-server.js
```
