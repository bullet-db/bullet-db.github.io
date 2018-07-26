# Navigating the UI

All videos in this page are running on the topology set up in the [Quick Start on Storm](../quick-start/storm.md) (producing *200 data records every second.*).

Clicking the ![info](../img/info.png) icon will display useful information.

## A simple first query

The default new query will get a raw record with max result count 1 - it will return when a single record is found.

### Results

Since there is no projection in this query, the results are shown as a JSON. You can click the Show as Table button to switch the mode.

**Example: Picking a random record from the stream**

<iframe width="900" height="508" src="https://www.youtube.com/embed/HHwf5wurJ-c?autoplay=1&loop=1&playlist=HHwf5wurJ-c" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

## Filtering and projecting data

The **Filters** section allows you to [pick a slice of data](../ws/api-json.md#filters) from the data stream.

The **Output Data** section allows you to retrieve a subset of fields, and optionally rename them. You can also aggregate data, or choose to see raw data records.

**Example: Finding and picking out fields from events that have probability > 0.5**

<iframe width="900" height="508" src="https://www.youtube.com/embed/TvDjwOMRbX0?autoplay=0&loop=0&playlist=TvDjwOMRbX0" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

## Stream Raw Events

A simple but useful query is a query with a filter and a [Sliding Window of size 1](../ws/api/#sliding-reactive-windows). This query will run for the extent of your duration and stream back events that match your filters as they arrive:

<iframe width="900" height="508" src="https://www.youtube.com/embed/y2Gzs27OjSw?autoplay=0&loop=0&playlist=y2Gzs27OjSw" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

**Be careful** when you use this query to ensure that your filter is sufficient to avoid returning TOO many results too fast. If this occurs Bullet will kill your query because of rate limiting (the default rate limit is 500 records per second).

## Tumbling Windows

[Time-Based Tumbling Windows](../ws/api/#time-based-tumbling-windows) will return results every X seconds:

<iframe width="900" height="508" src="https://www.youtube.com/embed/smy6jNfCVs4?autoplay=0&loop=0&playlist=smy6jNfCVs4" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

This example groups-by "type" and computes a couple metrics for each 2 second window.

## Additive Tumbling Windows

[Additive tumbling windows](../ws/api/#additive-tumbling-windows) will also return results every X seconds, but the results will contain all the data collected since the beginning of the query:

<iframe width="900" height="508" src="https://www.youtube.com/embed/goqUSJocN9c?autoplay=0&loop=0&playlist=goqUSJocN9c" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

In this example we compute bucket'ed frequency for the "gaussian" field. As the query runs you can see the gaussian curve form.

## Complex Filtering

The querybuilder allows you create nested filters (basic relational filters, ANDs and ORs).

The querybuilder is also type aware: Numeric fields only allow numeric values, String fields only allow String operation, etc.

**Example: Finding and picking out the first and second events in each period that also have probability > 0.5**

<iframe width="900" height="508" src="https://www.youtube.com/embed/08NLVbmk1ww?autoplay=0&loop=0&playlist=08NLVbmk1ww" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

!!! note "What's the .* next to a field?"

    If you have a map that is not enumerated (the keys are not known upfront), there will be *two* selections for the field in the dropdowns. If you want to apply operations to the nested keys, you can choose the field with the ```.*```. This will display a free-form subfield selection input where you can specify the key. If you want to apply operations on the entire map, you will need to choose the field without the ```.*```

## Count Distinct

Count Distinct will count the number of distinct elements in a field exactly up to a threshold that is established when the backend is launched (16,384 in the example below).

After this threshold the count will be approximate. As this example demonstrates, information about the precision of the count can be found in the Metadata:

<iframe width="900" height="508" src="https://www.youtube.com/embed/gEVg9a89j24?autoplay=0&loop=0&playlist=gEVg9a89j24" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

!!! note "How Can Bullet Count Distinct Elements So Fast??"

    Bullet uses [Data Sketches](https://datasketches.github.io/) to preform the Count Distinct operation extremely quickly and using a configurable amount of memory. The size and precision of the Sketches used is configurable when the backend is launched. Data Sketches provide an estimate of computationally difficult measurements with provable error bounds. Information about the precision of the estimate (such as the Standard Deviations) is available in the Metadata.

##  Group all

Choosing the Grouped Data option with no fields will result in the metrics being applied to all the data that matches your filters (or the whole set if you have no filters).

**Example: Counting, summing and averaging on the whole dataset**

The metrics you apply on fields are all numeric presently. If you apply a metric on a non-numeric field, Bullet will try to **type-cast** your field into number and if it's not possible, the result will be ```null```. The result will also be ```null``` if the field was not present or no data matched your filters.

<iframe width="900" height="508" src="https://www.youtube.com/embed/JOBpNneToWs?autoplay=0&loop=0&playlist=JOBpNneToWs" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

!!! note "Are Grouped Data metrics approximate?"

    No, the results are all exact. See below to see what is approximated when you have too many unique group combinations.

##  Group by

You can also choose Group fields and perform metrics per group.

**Example: Grouping by tuple_number**

<iframe width="900" height="508" src="https://www.youtube.com/embed/xawvHq9-WYY?autoplay=0&loop=0&playlist=xawvHq9-WYY" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

!!! note "What happens if I group by uuid?"

    Try it out! If the number of unique group values exceeds the [maximum configured](../quick-start/storm.md#setting-up-the-example-bullet-topology) (we used 1024 for this example), you will receive a *uniform sample* across your unique group values. The results for your metrics however, are **not sampled**. It is the groups that are sampled on. This means that is **no** guarantee of order if you were expecting the *most popular* groups or similar. You should use the Top K query in that scenario.

!!! note "Why no Count Distinct after Grouping"

    At this time, we do not support counting distinct values per field because with the current implementation of Grouping, it would involve storing DataSketches within DataSketches. We are considering this in a future release however.

!!! note "Aha, sorting by tuple_number didn't sort properly!"

    Good job, eagle eyes! Unfortunately, whenever we group on fields, those fields become strings under the current implementation. Rather than convert them back at the end, we have currently decided to leave it as is. This means that in your results, if you try and sort by a grouped field, it will perform a lexicographical sort even if it was originally a number.

    However, this also means that you can actually group by any field - including non primitives such as maps and lists! The field will be converted to a string and that string will be used as the field's representation for uniqueness and grouping purposes.

## Distributions

In this example, we find distributions of the ```duration```  field. This field is generated randomly from 0 to 10,049, with a tendency to have values that are closer to 0. We should be able to see this using Bullet.

The "distribution" option allows you to pick a type of distribution:

* ```Quantiles``` lets you get various percentiles (e.g. 25th, 99th) of your numeric field
* ```Frequencies``` lets you break up the range of values of your field into intervals and get a count of how many values fell into each interval.
* ```Cumulative Frequencies``` does the same as ```Frequencies``` but each interval includes the counts of all the intervals prior to it.

Both ```Frequencies``` and ```Cumulative Frequencies``` also give you a probability of how likely a value is to fall into the interval.


You can read much more about this in the UI help by clicking the ```Need more help?``` link.

### Exact

**Example: Finding the various percentiles of duration**

<iframe width="900" height="508" src="https://www.youtube.com/embed/JB0HlEO3Cfs?autoplay=0&loop=0&playlist=JB0HlEO3Cfs" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

---

**Example: Finding some frequency counts of duration values in an interval**

<iframe width="900" height="508" src="https://www.youtube.com/embed/-_I7rp4Vj20?autoplay=0&loop=0&playlist=-_I7rp4Vj20" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

Try it out youtself and see what ```Cumulative Frequencies``` does!

### Approximate

**Example: Approximate quantile distribution**

<iframe width="900" height="508" src="https://www.youtube.com/embed/JDXnFEpU6iY?autoplay=0&loop=0&playlist=JDXnFEpU6iY" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

!!! note "Normalized Rank Error"

    To understand what this means, refer to the [explanation here](../ws/examples.md#normalized-rank-error). You can also refer to the help in the Result Metadata section.

## Top K

Top K lets you get the most *frequent items* or the *heavy hitters* for the values in a set of a fields.

### Exact

This example gets the Top 3 most popular ```type``` values (there are only 6 but this illustrates the idea).

<iframe width="900" height="508" src="https://www.youtube.com/embed/Heav0e5jE8g?autoplay=0&loop=0&playlist=Heav0e5jE8g" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

### Approximate

By adding ```duration``` into the fields, the number of unique values for ```(type, duration)``` is increased. However, because ```duration``` has a tendency to have low values, we will have some *frequent items*. The counts are now estimated. 

<iframe width="900" height="508" src="https://www.youtube.com/embed/hCHWy229Yhw?autoplay=0&loop=0&playlist=hCHWy229Yhw" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

!!! note "Maximum Count Error"

    The ```maximum_count_error``` value for this query was ```3```. This means that the difference between the upper bound and the lower bound of each count estimate is ```3```. Bullet returns the upper bound as the estimate so subtracting ```3``` from each count gives you the lower bound of the count. Note that some counts are closer to each other than the count error. For instance, ```(quux, 1)``` and ```(bar, 1)``` have counts ```79``` and ```78``` but their true counts could be from ```76 to 79``` and ```75 to 78``` respectively. This means that ```(bar, 1)``` could well be the most frequent item for this query.

## Charting

This example shows how to get a basic chart in Bullet. The charting and pivoting modes are only enabled for queries that are *not* Count Distinct or Group without Group Fields. This is because these results only have a single row and it does not make sense to graph them. They are enabled for all other queries.

The charting example below shows how to get a quick chart of a ```Group``` query with 3 metrics.

<iframe width="900" height="508" src="https://www.youtube.com/embed/vGlIylyUqyc?autoplay=0&loop=0&playlist=vGlIylyUqyc" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

## Pivoting

If the regular chart option is insufficient for your result (for instance, you have too many groups and metrics or you want to post-aggregate your results or remove outliers etc), then there is a advanced Pivot mode available when you are in the Chart option.

The Pivot option provides a drag-and-drop interface to drag fields to breakdown and aggregate by their values. Operations such as finding standard deviations, variance, etc are available as well as easily viewing them as tables and charts. 

The following example shows a ```Group``` query with multiple groups and metrics and some interactions with the Pivot table.

<iframe width="900" height="508" src="https://www.youtube.com/embed/Y4qPvS65Ik0?autoplay=0&loop=0&playlist=Y4qPvS65Ik0" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

!!! note "Raw data does have a regular chart mode option"

    This is deliberate since the Chart option tries to infer your independent and dependent columns. When you fetch raw data, this is prone to errors so only the Pivot option is allowed.

