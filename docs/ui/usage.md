# Navigating the UI

The UI should (hopefully) be self-explanatory. Any particular section that requires additional information has the ![info](../img/info.png) icon next to it. Clicking this will display information relevant to that section.

The interactions in this page are running on the topology that was set up in the [Quick Start on Storm](../quick-start/storm.md).  Recall that that example backend is configured to produce *20 data records every 101 ms.*.

!!! note "NOTE: Some of these videos use an old version of the Bullet UI"
    We are currently in progress adding new videos with windowing and other new features from the latest UI version etc.

## Landing page

Loading the UI takes you to a page that shows all the queries and past results. You can edit, delete and copy your existing queries here. You can also view or clear your past results for the queries.

The help links you [configure  for the UI](setup.md#configuration) are shown in the Help menu.

### Schema

The schema you [plug into the UI](setup.md#configuration) is shown here so the users can better understand what the columns mean. Enumerated map fails can be expanded and their nested fields are also described.

**Example: The landing and schema pages**

<video controls autoplay loop>
  <source src="../../video/schema-2.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

!!! note "About tables"

    All tables in the UI, the table for the existing queries, the existing results, the schema or for a query result are all infinite-scroll type tables - they only show a fixed amount but if you scroll to the end, they automatically load more. The tables can all be sorted by clicking on the column name.

## A simple first query

If you create a new query, it defaults to getting a raw data record. This query returns immediately even though the maximum duration is set to 20s because the [Quick Start topology](../quick-start/storm.md#storm-topology) produces about 200 records/s and we are looking for one record with no filters.

### Results

Since the entire record was asked to be returned instead of particular fields, the result defaults to a JSON view of the data. You can click the Show as Table button to switch the mode. In this mode, you can click on each cell to get a popover showing the data formatted.

You can also download the results in JSON, CSV or flattened CSV (fields inside maps and lists are exploded). Any metadata returned for the query is collapsed by default. Any relevant metadata for the query [as configured](../quick-start/storm.md#setting-up-the-example-bullet-topology) is shown here. As always the help icons display help messages for each section.

**Example: Picking a random record from the stream**

<video controls autoplay loop>
  <source src="../../video/first-query-2.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

## Filtering and projecting data

The Filters section in the UI features a querybuilder (a modified version of the [jQuery-QueryBuilder](http://querybuilder.js.org/)) that you can use to add filters. These allow you to [pick at the slice of data](../ws/api.md#filters) from your stream that is relevant to you.

The Output Data section lets you aggregate or choose to see raw data records. You can either get all the data as [above](#a-simple-first-query) or you can select a subset of fields (and optionally rename them) that you would like to see.

**Example: Finding and picking out fields from events that have probability > 0.5**

<video controls autoplay loop>
  <source src="../../video/filter-project-2.mp4" type="video/mp4">
  Your browser does not support the video tag
</video>

!!! note "Default result display"

    If you choose the Show All Fields selection in the Output Data option, the results will default to the JSON data view. Otherwise, it defaults to the table.

## Stream Raw Events

**Note:** This query is only available in the Bullet UI version 0.5.0 and later.

A very simple but useful query is a query with a filter and a [Sliding Window of size 1](../ws/api/#sliding-reactive-windows). This query will run for the extent of your duration and stream back events that match your filters as they arrive:

<iframe width="900" height="508" src="https://www.youtube.com/embed/y2Gzs27OjSw?autoplay=1&loop=1&playlist=y2Gzs27OjSw" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

**Be careful** when you use this query to ensure that your filter is sufficient to avoid returning TOO many results too fast. If this occurs Bullet will kill your query because of rate limiting (the default rate limit is 500 records per second).

## Tumbling Windows

**Note:** This query is only available in the Bullet UI version 0.5.0 and later.

[Time-Based Tumbling Windows](../ws/api/#time-based-tumbling-windows) will return results every X seconds:

<iframe width="900" height="508" src="https://www.youtube.com/embed/smy6jNfCVs4?autoplay=1&loop=1&playlist=smy6jNfCVs4" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

This example groups-by "type" and computes a couple metrics for each 2 second window.

## Additive Tumbling Windows

**Note:** This query is only available in the Bullet UI version 0.5.0 and later.

[Additive tumbling windows](../ws/api/#additive-tumbling-windows) will also return results every X seconds, but the results will contain all the data collected since the beginning of the query:

<iframe iframe width="900" height="508" src="https://www.youtube.com/embed/Lu7vSuv1NYA?autoplay=1&loop=1&playlist=Lu7vSuv1NYA" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

In this example we compute bucket'ed frequency for the "probability" field. You can see from the scale of the Y axis that these computations are accumulated over the life of the query.

### Complex Filtering

The querybuilder also lets you easily create nested filters. You can add basic relational filters or group a set of basic filters by connecting them with ANDs and ORs. You can also drag and drop filters and groups.

The querybuilder is also type aware. The operations you can perform change based on the type. Numeric fields only allow numeric values. String fields allow you to apply regular expressions to them or specify multiple values at the same time using a ```,```. Boolean fields only allow you to choose a radio button etc.

**Example: Finding and picking out the first and second events in each period that also have probability > 0.5**

<video controls autoplay loop>
  <source src="../../video/query-building-2.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

!!! note "What's the .* next to a field?"

    If you have a map that is not enumerated (the keys are not known upfront), there will be *two* selections for the field in the dropdowns. If you want to apply operations to the nested keys, you can choose the field with the ```.*```. This will display a free-form subfield selection input where you can specify the key. If you want to apply operations on the entire map, you will need to choose the field without the ```.*```

## Count Distinct

### Exact

The settings you had [configured when launching](../quick-start/storm.md#step-5-setup-the-storm-example) the backend determines the number of unique values that Bullet can [count exactly](../index.md#approximate-computation). The example UI shown here used the default configuration value of ```16384``` that the example provided, so for all Count Distinct queries where the cardinality of the field combination is less than this number, the result is exact. The metadata also reflects this.

You can also optionally rename the result.

**Example: Counting unique UUIDs for 20s**

<video controls autoplay loop>
  <source src="../../video/exact-count-distinct-3.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

!!! note "Shouldn't the count be slightly more in the last example?"

    **Short answer:** Yes and it's because of the synthetic nature of the data generation.

    **Long answer:** We should have had ```20000 ms / 101 ms``` or ```198``` periods or ```198 periods * 20 tuples/period``` or ```3960``` tuples with unique values for the```uuid``` field. The example spout generates data in bursts of 20 at the start of every period (101 ms). However, the delay isn't exactly 101 ms between periods; it's a bit more depending on when Storm decided to run the emission code. As a result, every period will slowly add a delay of a few ms. Eventually, this can lead us to missing an entire period. This increases the longer the query runs. Even a delay of 1 ms every period (a very likely scenario) can add up to 101 ms or 1 period in as short a time as a 101 periods or ```101 periods * 101 ms/period``` or ```~10 s```. A good rule of thumb is that for every 10 s your query runs, you are missing 20 tuples. You might also miss another 20 tuples at the beginning or the end of the window since the spout is bursty.

    In most real streaming scenarios, data should be constantly flowing and there shouldn't delays building like this. Even so, for a distributed, streaming system like Bullet, you should always remember that data can be missed at either end of your query window due to inherent skews and timing issues.

!!! note "Why did the Maximum Records input disappear?"

    Maximum Records as a query stopping criteria only makes sense when you are picking out raw records. While the API still supports using it as a limiting mechanism on the number of records that are returned to you, the UI eschews this and sets it to a value that you can [configure](setup.md#configuration). It is also particularly confusing to see a Maximum Records when you are doing a Count Distinct operation, while it makes sense when you are Grouping data. You should ideally set this to the same value as your maximum aggregation size that you configure when launching your backend.

### Approximate

When the result is approximate, it is shown as a decimal value. The Result Metadata section will reflect that the result was estimated and provide you standard deviations for the true value. The errors are derived from [DataSketches here](https://datasketches.github.io/docs/Theta/ThetaErrorTable.html). Note the line for ```16384```, which was what we configured for the maximum unique values for the Count Distinct operation. In the example below, this means if we want 99.73% confidence for the result, the ```3``` standard deviation entry says that the true count could vary from ```38194``` to ```39590```.

**Example: Counting unique UUIDs for 200s**

<video controls autoplay loop>
  <source src="../../video/approx-count-distinct-3.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

!!! note "So why is the approximate count what it is?"

    The backend should have produced ```20 * 200000/101``` or ```39603``` tuples with unique uuids. Due to the synthetic nature of the data generation and the building delays mentioned above, we estimated that we should subtract about 20 tuples for every 10 s the query runs. Since this query ran for ```200 s```, this makes the actual uuids generated to be at best ```39603 - (200/10) * 20``` or ```39203```. The result from Bullet was ```39069```, which is an error of ```~0.3 %```. The real error is probably less than that because we assumed the delay between periods to be 1 ms to get the ```39203``` number. It's probably slightly larger making the actual uuids generated lower and closer to our estimate.

##  Group all

When choosing the Grouped Data option, you can choose to add fields to group by. If you do not and you add metrics, they will apply to all the data that matches your filters (or the whole data set if you don't have any).

**Example: Counting, summing and averaging on the whole dataset**

The metrics you apply on fields are all numeric presently. If you apply a metric on a non-numeric field, Bullet will try to **type-cast** your field into number and if it's not possible, the result will be ```null```. The result will also be ```null``` if the field was not present or no data matched your filters.

<video controls autoplay loop>
  <source src="../../video/group-all-error-2.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

!!! note "Errors when building queries"

    Errors that can be readily displayed are shown immediately. Some errors like the ones in the example above are only shown when you try to run or save the query.

!!! note "Are Grouped Data metrics approximate?"

    No, the results are all exact. See below to see what is approximated when you have too many unique group combinations.

##  Group by

You can also choose Group fields and perform metrics per group. If you do not add any Metric fields, you will be **performing a distinct operation** on your group fields.

**Example: Grouping by tuple_number**

In this example, we group by ```tuple_number```. Recall that this is the number assigned to a tuple within a period. They range from 0 to 19. If we group by this, we expect to have 20 unique groups. In 5s, we have ```5000/101``` or ```49``` periods. Each period has one of each ```tuple_number```. We expect ```49``` as the count for each group, and this what we see. The building delays mentioned [in the note above](#exact) has not really started affecting the data yet. Note that the average is also roughly ```0.50``` since the ```probability``` field is a uniformly distributed value between 0 and 1.

<video controls autoplay loop>
  <source src="../../video/group-by-with-cancel-2.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

!!! note "What happens if I group by uuid?"

    Try it out! Nothing bad should happen. If the number of unique group values exceeds the [maximum configured](../quick-start/storm.md#setting-up-the-example-bullet-topology) (we used 1024 for this example), you will receive a *uniform sample* across your unique group values. The results for your metrics however, are **not sampled**. It is the groups that are sampled on. This means that is **no** guarantee of order if you were expecting the *most popular* groups or similar. You should use the Top K query in that scenario.

!!! note "Why no Count Distinct after Grouping"

    At this time, we do not support counting distinct values per field because with the current implementation of Grouping, it would involve storing DataSketches within DataSketches. We are considering this in a future release however.

!!! note "Aha, sorting by tuple_number didn't sort properly!"

    Good job, eagle eyes! Unfortunately, whenever we group on fields, those fields become strings under the current implementation. Rather than convert them back at the end, we have currently decided to leave it as is. This means that in your results, if you try and sort by a grouped field, it will perform a lexicographical sort even if it was originally a number.

    However, this also means that you can actually group by any field - including non primitives such as maps and lists! The field will be converted to a string and that string will be used as the field's representation for uniqueness and grouping purposes.

## Distributions

In this example, we find distributions of the ```duration```  field. This field is generated randomly from 0 to 10,049, with a tendency to have values that are closer to 0 than 10,049. Let's see if this is true. Note that since this field has random values, the results you see per query are the values generated during that query's duration.

The distribution type of output data requires you to pick a type of distribution: ```Quantiles```, ```Frequencies``` or ```Cumulative Frequencies```. ```Quantiles``` lets you get various percentiles (e.g. 25th, 99th) of your numeric field. ```Frequencies``` lets you break up the range of values of your field into intervals and get a count of how many values fell into each interval. ```Cumulative Frequencies``` does the same as ```Frequencies``` but each interval includes the counts of all the intervals prior to it. Both ```Frequencies``` and ```Cumulative Frequencies``` also give you a probability of how likely a value is to fall into the interval.

All the distributions require you to specify some numeric points. For ```Quantiles```, these points are between 0 and 1 and the value denotes the percentile you are looking for. (0.25 for 25th percentile, 0.99 for 99th etc). For ```Frequencies``` and ```Cumulative Frequencies```, the points are between the minimum and maximum value of your field and every 2 contiguous points create an interval. However, the first interval always starts from *-&infin;* to the first point and the last interval always starts from your last point to *+&infin;*.

You can read much more about this in the UI help by clicking the ```Need more help?``` link.

### Exact

**Example: Finding the various percentiles of duration**

This example shows all 3 values of specifying points and shows *exact* distribution results for the ```duration``` field.

<video controls autoplay loop>
  <source src="../../video/quantiles-all-point-formats.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

---

**Example: Finding some frequency counts of duration values in an interval**

The last example showed that the 90th percentile of ```duration``` was around 4000. This example gets some frequencies in various intervals.

<video controls autoplay loop>
  <source src="../../video/frequency-distribution.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

Try out and see what ```Cumulative Frequencies``` does yourself!

### Approximate

This next example shows how an approximate distribution result looks.

**Example: Approximate quantile distribution**

<video controls autoplay loop>
  <source src="../../video/approx-quantile.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

!!! note "Normalized Rank Error"

    To understand what this means, refer to the [explanation here](../ws/examples.md#normalized-rank-error). You can also refer to the help in the Result Metadata section.

## Top K

Top K lets you get the most *frequent items* or the *heavy hitters* for the values in a set of a fields.

### Exact

This example gets the Top 3 most popular ```type``` values (there are only 6 but this illustrates the idea).

<video controls autoplay loop>
  <source src="../../video/exact-top-k.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

### Approximate

By adding ```duration``` into the fields, the number of unique values for ```(type, duration)``` is increased. However, because ```duration``` has a tendency to have low values, we will have some *frequent items*. The counts are now estimated. We ask for the top 300 results but we also say that they should have a count of at least 20. This restricts the overall number of results to 12.

<video controls autoplay loop>
  <source src="../../video/approx-top-k.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

!!! note "Maximum Count Error"

    The ```maximum_count_error``` value for the query above was ```3```. This means that the difference between the upper bound and the lower bound of each count estimate is ```3```. Bullet returns the upper bound as the estimate so subtracting ```3``` from each count gives you the lower bound of the count. Note that some counts are closer to each other than the count error. For instance, ```(quux, 1)``` and ```(baz, 0)``` have counts ```67``` and ```66``` but their true counts could be from ```64 to 67``` and ```63 to 66``` respectively. This means that ```(baz, 0)``` could well be the most frequent item for this query.

## Charting

[Bullet UI v0.3.0 and above](https://github.com/bullet-db/bullet-ui/releases/tag/v0.3.0) added support for charting and pivoting. This example shows how to get a basic chart on [Bullet UI v0.3.1](https://github.com/bullet-db/bullet-ui/releases/tag/v0.3.1). If you are following the [Quick Start on Storm](../quick-start/storm.md), then this should be in your UI. The charting and pivoting modes are only enabled for queries that are *not* Count Distinct or Group without Group Fields. This is because these results only have a single row and it does not make sense to graph them. They are enabled for all other queries.

The charting example below shows how to get a quick chart of a ```Group``` query with 3 metrics.

<video controls autoplay loop>
  <source src="../../video/charting.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

## Pivoting

If the regular chart option is insufficient for your result (for instance, you have too many groups and metrics or you want to post-aggregate your results or remove outliers etc), then there is a advanced Pivot mode available when you are in the Chart option. The Pivot option provides a drag-and-drop interface to drag fields to breakdown and aggregate by their values. Operations such as finding standard deviations, variance, average, median, sum over sums etc are available as well as easily viewing them as tables and charts. The following example shows a ```Group``` query with multiple groups and metrics and some interactions with the Pivot table.

!!! note "Raw data does not seem to have a regular chart mode option"

    This is deliberate since the Chart option tries to infer your independent and dependent columns. When you fetch raw data, this is prone to errors so only the Pivot option is allowed. You can always graph within the Pivot option if you need to.
<video controls autoplay loop>
  <source src="../../video/pivoting.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>
