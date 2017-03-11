# Navigating the UI

The UI should (hopefully) be self-explanatory. Any particular section that requires additional information has the ![info](../img/info.png) icon next to it. Clicking this will display information relevant to that section. The interactions in this page are running on the topology that was set up in the [Quick Start](../quick-start.md). Recall that the example backend is configured to produce *20 data records every 101 ms.*


## Landing page

Loading the UI takes you to a page that shows all the queries and past results. You can edit, delete and copy your existing queries here. You can also view or clear your past results for the queries.

The help links you [configure  for the UI](setup.md#configuration) are shown in the Help menu.

### Schema

The schema you [plug into the UI](setup.md#configuration) is shown here so the users can better understand what the columns mean. Enumerated map fails can be expanded and their nested fields are also described.

**Example: The landing and schema pages**

<video controls autoplay loop>
  <source src="../../video/schema.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

!!! note "About tables"

    All tables in the UI, the table for the existing queries, the existing results, the schema or for a query result are all infinite-scroll type tables - they only show a fixed amount but if you scroll to the end, they automatically load more. The tables can all be sorted by clicking on the column name.

## A simple first query

If you create a new query, it defaults to getting a raw data record. This query returns immediately even though the maximum duration is set to 20s because the [Quick Start topology](../quick-start.md#storm-topology) produces about 200 records/s and we are looking for one record with no filters.

### Results

Since the entire record was asked to be returned instead of particular fields, the result defaults to a JSON view of the data. You can click the Show as Table button to switch the mode. In this mode, you can click on each cell to get a popover showing the data formatted.

You can also download the results in JSON, CSV or flattened CSV (fields inside maps and lists are exploded). Any metadata returned for the query is collapsed by default. Any relevant metadata for the query [as configured](../quick-start.md#setting-up-the-example-bullet-topology) is shown here. As always the help icons display help messages for each section.

**Example: Picking a random record from the stream**

<video controls autoplay loop>
  <source src="../../video/first-query.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

!!! note "__receive_timestamp"

    This was enabled as part of the configuration for the example backend. This was the timestamp when Bullet first saw this record. If you have timestamps in your data (as this example does), you will be able to tell exactly when your data was received by Bullet. This coupled with the timestamps in the Result Metadata for when your query was submitted and terminated, you will be able to tell why or why not a particular record was or was not seen in Bullet.

## Filtering and projecting data

The Filters section in the UI features a querybuilder (a modified version of the [jQuery-QueryBuilder](http://querybuilder.js.org/)) that you can use to add filters. These allow you to [pick at the slice of data](../ws/api.md#filters) from your stream that is relevant to you.

The Output Data section lets you aggregate or choose to see raw data records. You can either get all the data as [above](#a-simple-first-query) or you can select a subset of fields (and optionally rename them) that you would like to see.

**Example: Finding and picking out fields from events that have probability > 0.5**

<video controls autoplay loop>
  <source src="../../video/filter-project.mp4" type="video/mp4">
  Your browser does not support the video tag
</video>

!!! note "Default result display"

    If you choose the Show All Fields selection in the Output Data option, the results will default to the JSON data view. Otherwise, it defaults to the table.

### Complex Filtering

The querybuilder also lets you easily create nested filters. You can add rules to add basic relational filters or group a set of filters by connecting them with ANDs and ORs. You can also drag and drop rules and groups.

The querybuilder is also type aware. The operations you can perform change based on the type. Numeric fields only allow numeric values. String fields allow you to apply regular expressions to them or specify multiple values at the same time using a ```,```. Boolean fields only allow you to choose a radio button etc.

**Example: Finding and picking out the first and second events in each period that also have probability > 0.5**

<video controls autoplay loop>
  <source src="../../video/query-building.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

!!! note "What's the .* next to a field?"

    If you have a map that is not enumerated (the keys are not known upfront), there will be *two* selections for the field in the dropdowns. If you want to apply operations to the nested keys, you can choose the field with the ```.*```. This will display a free-form subfield selection input where you can specify the key. If you want to apply operations on the entire map, you will need to choose the field without the ```.*```

## Count Distinct

### Exact

The settings you had [configured when launching](../quick-start.md#step-5-setup-the-storm-example) the backend determines the number of unique values that Bullet can [count exactly](../index.md#approximate-computation). The example UI shown here used the default configuration value of ```16384``` that the example provided, so for all Count Distinct queries where the cardinality of the field combination is less than this number, the result is exact. The metadata also reflects this.

You can also optionally rename the result.

**Example: Counting unique UUIDs for 20s**

<video controls autoplay loop>
  <source src="../../video/exact-count-distinct.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

!!! note "Shouldn't the count be slightly less in the last example?"

    The result is ```4040``` in the example is because of [the tick-based design](../backend/storm-architecture.md#topology). Everything in the Storm topology with respect to queries happens with ticks and since our tick granularity is set to 1s, that is our lowest visibility. Depending on when that last tick happened, the result could be off by as much as 1s worth of data. For this example, we should have had ```20000 ms / 101 ms``` or ```198``` periods or ```198 periods * 20 tuples/period``` or ```3960``` tuples.  But since we can be off by 1s and we can produce ```20 * 1000/101``` or ```80``` tuples in that time, the result is ```4040```. You can always account for this by running your query with a duration that is 1 s shorter than what you desired.

!!! note "Why did the Maximum Records input disappear?"

    Maximum Records as a query stopping criteria only makes sense when you are picking out raw records. While the API still supports using it as a limiting mechanism on the number of records that are returned to you, the UI eschews this and sets it to a value that you can [configure](setup.md#configuration). It is also particularly confusing to see a Maximum Records when you are doing a Count Distinct operation, while it makes sense when you are Grouping data. You should ideally set this to the same value as your maximum aggregation size that you configure when launching your backend.

### Approximate

When the result is approximate, it is shown as a decimal value. The Result Metadata section will reflect that the result was estimated and provide you standard deviations for the true value. The errors are derived from [DataSketches here](https://datasketches.github.io/docs/Theta/ThetaErrorTable.html). Note the line for ```16384```, which was what we configured for the maximum unique values for the Count Distinct operation. That means if we want 99.73% confidence for the result, the ```3``` standard deviation entry says that the true count could vary from ```38603``` to ```40017```. The backend should have produced ```20 * 200000/101``` or ```39603``` tuples with unique uuids. The result from Bullet was ```39304```, which is pretty close.

**Example: Counting unique UUIDs for 200s**

<video controls autoplay loop>
  <source src="../../video/approx-count-distinct.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

!!! note "What about the tick granularity here?"

    The 1s tick granularity still only affects the data by 80, so it can be largely ignored here.

##  Group all

When choosing the Grouped Data option, you can choose to add fields to group by. If you do not and you add metrics, they will apply to all the data that matches your filters (or the whole data set if you don't have any).

**Example: Counting, summing and averaging on the whole dataset**

The metrics you apply on fields are all numeric presently. If you apply a metric on a non-numeric field, Bullet will try to **type-cast** your field into number and if it's not possible, the result will be ```null```. The result will also be ```null``` if the field was not present or no data matched your filters.

<video controls autoplay loop>
  <source src="../../video/group-all-error-duplicating.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

!!! note "Errors when building queries"

    Errors that can be readily displayed are shown immediately. Some errors like the ones in the example above are only shown when you try to run or save the query.

!!! note "Are Grouped Data metrics approximate?"

    No, the results are all exact. See below to see what is approximated when you have too many unique group combinations.

##  Group by

You can also choose Group fields and perform metrics per group. If you do not add any Metric fields, you will be **performing a distinct operation** on your group fields.

**Example: Grouping by tuple_number**

In this example, we group by ```tuple_number```. Recall that this is the number assigned to a tuple within a period. They range from 0 to 19. If we group by this, we expect to have 20 unique groups. In 20s, we have ```20000/101``` or ```198``` periods. Each period has one of each ```tuple_number```. With the 1s tick granulaity, we expect ```199``` as the count for each group, which is what is seen in the results. Note that the average is also roughly ```0.50``` since the ```probability``` field is a uniformly distributed value between 0 and 1.

<video controls autoplay loop>
  <source src="../../video/group-by-with-cancel.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

!!! note "What happens if I group by uuid?"

    Try it out! If the number of unique group values exceeds the [maximum configured](../quick-start.md#setting-up-the-example-bullet-topology) (we used 1024 for this example), you will receive a *uniform sample* across your unique group values. The results for your metrics however, are **not sampled**. It is the groups that are sampled on. This means that is **no** guarantee of order if you were expecting the *most popular* groups or something. We are working on adding a ```TOP K``` query that can support these kinds of use-cases.

!!! note "Why no Count Distinct after Grouping"

    At this time, we do not support counting distinct values per field because with the current implementation of Grouping, it would involve storing Data Sketches within Data Sketches. We are considering this in a future release however.
