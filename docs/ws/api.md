# API

See the [UI Usage section](../ui/usage.md) for using the UI to build Bullet queries. This section deals with examples of the JSON query format that the API currently exposes (and the UI uses underneath).

Bullet queries allow you to filter, project and aggregate data. It lets you fetch raw and aggregated data. Fields inside maps can be accessed using the '.' notation in queries. For example, myMap.key will access the key field inside the myMap map. There is no support for accessing fields inside Lists or inside nested Maps as of yet. Only the entire object can be operated on for now.

The three main sections of a Bullet query are:
```javascript
{
    "filters": {},
    "projection": {},
    "aggregation": {}.
    "duration": 20000
}
```
The duration represents how long the query runs for (a window from when you submit it to that many milliseconds into the future). See the [Filters](#filters), [Projections](#projections) and [Aggregation](#aggregations) sections for their respective specifications. Each of those sections are objects.

## Filters

Bullet supports two kinds of filters:

1. Logical filters
2. Relational filters

### Logical Filters

Logical filters allow you to combine other filter clauses with logical operations like ```AND```, ```OR``` and ```NOT```.

The current logical operators allowed in filters are:

| Logical Operator | Meaning |
| ---------------- | ------- |
| AND              | All filters must be true. The first false filter evaluated left to right will short-circuit the computation. |
| OR               | Any filter must be true. The first true filter evaluated left to right will short-circuit the computation. |
| NOT              | Negates the value of the first filter clause. The filter is satisfied iff the value is true. |

The format for a Logical filter is:

```javascript
{
   "operation": "AND | OR | NOT"
   "clauses": [
      {"operation": "...", clauses: [{}, ...]},
      {"field": "...", "operation": "", values: ["..."]},
      {"operation": "...", clauses: [{}, ...]}
      ...
   ]
}
```

Any other type of filter may be provided as a clause in clauses.

### Relational Filters

Relational filters allow you to specify conditions on a field, using a comparison operator and a list of values.

The current comparisons allowed in filters are:

| Comparison | Meaning |
| ---------- | ------- |
| ==         | Equal to any value in values |
| !=         | Not equal to any value in values |
| <=         | Less than or equal to any value in values |
| >=         | Greater than or equal to any value in values |
| <          | Less than any value in values |
| >          | Greater than any value in values |
| RLIKE      | Matches using [Java Regex notation](http://docs.oracle.com/javase/7/docs/api/java/util/regex/Pattern.html), any Regex value in values |

These operators are all typed based on the type of the left hand side from the Bullet record. If the elements on the right hand side cannot be
casted to the types on the LHS, those items will be ignored for the comparison.

The format for a Relational filter is:

```javascript
{
    "operation": "== | != | <= | >= | < | > | RLIKE"
    "field": "record_field_name | map_field.subfield",
    "values": [
        "string values",
        "that go here",
        "will be casted",
        "to the",
        "type of field"
    ]
}
```
*Multiple top level relational filters behave as if they are ANDed together.* This is supported as a convenience to do a bunch of ```AND```ed relational filters without having to nest them in a logical clause.

## Projections
Projections allow you to pull out only the fields needed and rename them (renaming is being supported in order to give
better names to fields pulled out from maps). If projections are not specified, the entire record is returned. If you are querying
for raw records, you can use projections to help reduce the load on the system and network.

```javascript
{
    "projection": {
        "fieldA": "newNameA",
        "fieldB": "newNameB"
    }
}
```

## Aggregations

Aggregations allow you to perform some operation on the collected records. They take an optional size to restrict
the size of the aggregation (this applies for aggregations high cardinality aggregations and raw records).

The current aggregation types that are supported are:

| Aggregation    | Meaning |
| -------------- | ------- |
| GROUP          | The resulting output would be a record containing the result of an operation for each unique group in the specified fields |
| COUNT DISTINCT | Computes the number of distinct elements in the fields. (May be approximate) |
| LIMIT          | The resulting output would be at most the number specified in size. |
| DISTRIBUTION   | Computes distributions of the elements in the field. E.g. Find the median value or various percentile of a field, or get frequency or cumulative frequency distributions |
| TOP K          | Returns the top K most frequently appearing values in the column |

The current format for an aggregation is:

```javascript
{
    "type": "GROUP | COUNT DISTINCT | TOP | PERCENTILE | RAW",
    "size": <a limit on the number of resulting records>,
    "fields": {
        "fields": "newNameA",
        "that go here": "newNameB",
        "are what the": "newNameC",
        "aggregation type applies to": "newNameD"
    },
    "attributes": {
        "these": "change",
        "per": [
           "aggregation type"
        ]
    }
}
```

You can also use ```LIMIT``` as an alias for ```RAW```. ```DISTINCT``` is also an alias for ```GROUP```. These exist to make some queries read a bit better.

Currently we support GROUP aggregations on the following operations:

| Operation      | Meaning |
| -------------- | ------- |
| COUNT          | Computes the number of the elements in the group |
| SUM            | Computes the sum of the elements in the group |
| MIN            | Returns the minimum of the elements in the group |
| MAX            | Returns the maximum of the elements in the group |
| AVG            | Computes the average of the elements in the group |


### Attributes

The ```attributes``` section changes per aggregation ```type```.

#### GROUP

The following attributes are supported for ```GROUP```:

```javascript
    "attributes": {
        "operations": [
            {
                "type": "COUNT",
                "newName": "resultColumnName"
            },
            {
                "type": "SUM",
                "field": "fieldName",
                "newName": "resultColumnName"
            },
            {
                "type": "MIN",
                "field": "fieldName",
                "newName": "resultColumnName"
            },
            {
                "type": "MAX",
                "field": "fieldName",
                "newName": "resultColumnName"
            },
            {
                "type": "AVG",
                "field": "fieldName",
                "newName": "resultColumnName"
            }
        ]
    }
```

You can perform ```SUM```, ```MIN```, ```MAX```, ```AVG``` on non-numeric fields. Bullet will attempt to *cast the field to a number first.* If it cannot, that record with the field will be ignored for the operation. For the purposes of ```AVG```, Bullet will
perform the average across the numeric values for a field only.

#### COUNT DISTINCT

The following attributes are supported for ```COUNT DISTINCT```:

```javascript
    "attributes": {
        "newName": "resultCountColumnName"
    }
```

Note that the new names you specify in the fields map for aggregations do not apply. You must use the attributes here to give your resulting output count column a name.

#### DISTRIBUTION

The following attributes are supported for ```DISTRIBUTION```:

```javascript
    "attributes": {
        "type": "QUANTILE | PMF | CDF",
        "numberOfPoints": <a number of evenly generated points to generate>,
        "points": [ a, free, form, list, of, numbers ],
        "start": <a start of the range to generate points>,
        "end": <the end of the range to generate points>,
        "increment": <the increment between the generated points>,
    }
```

You *must* specify one and only one field using the ```fields``` section in ```aggregation```. Any ```newName``` you provide will be ignored.

The ```type``` field picks the type of distribution to apply.

|   Type   |    Meaning    |
| -------- | ------------- |
| QUANTILE | Lets you pick out percentiles of the numeric field you provide. |
| PMF      | The Probability Mass Function distribution lets you get frequency counts and probabilities of ranges or intervals of your numeric field |
| CDF      | The Cumulative Distribution Function distribution lets you get cumulative frequency counts instead and is otherwise similar to PMF |

Depending on what ```type``` you have chosen, the rest of the attributes define *points in the domain* of that distribution.

For ```QUANTILE```, the points you define will be the *values* to get the percentiles from. These percentiles are represented as numbers between 0 and 1. This means that your points *must* be between 0 and 1.

For ```PMF``` and ```CDF```, the points you define will *partition* the range of your field values into intervals, with the first interval going from -&infin; to the first point and the last interval from your last point to +&infin;. This means that if you generate *N* points, you will receive *N+1* intervals. The points you define should be in the range of the values for your field to get a meaningful distribution. The domain for your points is therefore, all real numbers but you should narrow down to valid values for the field to get meaningful results.

You have three options to generate points.

|           Method           |    Keys          |
| -------------------------- | ---------------- |
| Number of Points           | You can use the ```numberOfPoints``` key to provide a number of points to generate evenly distributed in the full range of your domain |  
| Generate Points in a range | You can use ```start```, ```end``` and ```increment``` (```start``` < ```end```, ```increment``` > 0) to specify numbers to generate points in a narrower region of your domain |
| Specify free-form points   | You can specify a free-form *array* of numbers which will be used as the points |

Note that If you specify more than one way to generate points, the API will use ```numberOfPoints```, followed by ```points```, followed by ```start```, ```end``` and ```increment``` and whichever creates valid points will be used first.

For ```PMF``` and ```CDF```, no matter how you specify your points, the first interval will always be *(-&infin;, first point)* and the last interval will be *[last point, +&infin;)*. You will also get a probability of how likely a value will land in the interval per interval in addition to a frequency (or cumulative frequency) count.

As with ```GROUP```, Bullet will attempt to *cast* your field into a numeric type and ignore it if it cannot.

#### TOP K

The following attributes are supported for ```TOP K```:

```javascript
  "attributes": {
      "threshold": <restrict results to having at least this count value>,
      "newName": "resultCountColumnName"
  }
```

Note that the ```K``` in ```TOP K``` is specified using the ```size``` field in the ```aggregation``` object.

## Results

Bullet results are JSON objects with two fields:

| Field   | Contents |
| ------- | -------- |
| records | This field contains the list of matching records |
| meta    | This field is a map that contains meta information about the query, such as the time the query was received, error data, etc. These are configurable at launch time. |

For a detailed description of how to perform these queries and see example results, see [Examples](examples.md).
