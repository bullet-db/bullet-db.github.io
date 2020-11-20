# Bullet API

This section gives a comprehensive overview of the Web Service API for launching Bullet queries.

For examples of queries, see the [examples page](examples.md).

BQL is the interface that is exposed to users to query Bullet. BQL queries that are received by the Web Service are converted to an underlying querying format before being sent to the backend. This conversion is done in the web service using [the bullet-bql library](../releases/#bullet-bql).

## Overview

Bullet-BQL provides users with a friendly SQL-like API to submit queries to the Web Service.

## Statement Syntax

    SELECT DISTINCT? select_clause
    FROM from_clause
    ( WHERE where_clause )?
    ( GROUP BY groupBy_clause )?
    ( HAVING having_clause )?
    ( ORDER BY orderBy_clause )?
    ( WINDOWING windowing_clause )?
    ( LIMIT limit_clause )?;

where `select_clause` is one of

    *
    COUNT( DISTINCT reference_expr ( , reference_expr )? )
    group_function ( AS? ColumnReference )? ( , group_function ( AS? ColumnReference )? )? ( , reference_expr ( AS? ColumnReference )? )?
    reference_expr ( AS? ColumnReference )? ( , reference_expr ( AS? ColumnReference )? )?
    distribution_type( reference_expr, input_mode ) ( AS? ColumnReference )?
    TOP ( ( Integer | Long ) ( , Integer | Long ) )? , reference_expr ( , reference_expr )? ) ( AS? ColumnReference )?


`reference_expr` is one of `ColumnReference` or `Dereference`.

and `group_function` is one of `SUM(reference_expr)`, `MIN(reference_expr)`, `MAX(reference_expr)`, `AVG(reference_expr)` and `COUNT(*)`. `reference_expr` is one of ColumnReference and Dereference. `distribution_type` is one of `QUANTILE`, `FREQ` and `CUMFREQ`. The 1st number in `TOP` is K, and the 2nd number is an optional threshold.  The `input_mode` is one of

    LINEAR, ( Integer | Long )                                              evenly spaced
    REGION, ( Integer | Long ), ( Integer | Long ), ( Integer | Long )      evenly spaced in a region
    MANUAL, ( Integer | Long ) (, ( Integer | Long ) )*                     defined points

and `from_clause` is one of

    STREAM()                                                          default time duration will be set from BQLConfig
    STREAM( ( Long | MAX ), TIME )                                    time based duration control.
    STREAM( ( Long | MAX ), TIME, ( Long | MAX ), RECORD )            time and record based duration control.

`RECORD` will be supported in the future.

and `where_clause` is one of

    NOT where_clause
    where_clause AND where_clause
    where_clause OR where_clause
    reference_expr IS NOT? NULL
    reference_expr IS NOT? EMPTY
    reference_expr IS NOT? DISTINCT FROM value_expr
    reference_expr NOT? BETWEEN value_expr AND value_expr
    reference_expr NOT? IN ( value_expr ( , value_expr )* )
    reference_expr NOT? LIKE ( value_expr ( , value_expr )* )
    reference_expr NOT? CONTAINSKEY ( value_expr ( , value_expr )* )
    reference_expr NOT? CONTAINSVALUE ( value_expr ( , value_expr )* )
    reference_expr ( = | <> | != | < | > | <= | >= ) value_expr
    SIZEOF(reference_expr) ( = | <> | != ) value_expr
    SIZEOF(reference_expr) NOT? IN ( value_expr ( , value_expr )* )
    SIZEOF(reference_expr) NOT? DISTINCT FROM value_expr

`value_expr` is one of Null, Boolean, Integer, Long, Double, Decimal, String or `reference_expr`.

and `groupBy_clause` is one of

    ()                                                                group all
    reference_expr ( , reference_expr )*                              group by
    ( reference_expr ( , reference_expr )* )                          group by

and `HAVING` and `ORDER BY` are only supported for TopK. In which case, `having_clause` is

    COUNT(*) >= Integer

and `orderBy_clause` is

    COUNT(*)

and `windowing_clause` is one of

    ( EVERY, ( Integer | Long ), ( TIME | RECORD ), include )
    ( TUMBLING, ( Integer | Long ), ( TIME | RECORD ) )

`include` is one of

    ALL
    FIRST, ( Integer | Long ), ( TIME | RECORD )
    LAST, ( Integer | Long ), ( TIME | RECORD )                       will be supported

and `limit_clause` is one of

    Integer | Long
    ALL                                                               will be supported

## Data Types

* **Null**: `NULL`.

* **Boolean**: `TRUE`, `FALSE`.

* **Integer**: 32-bit signed two’s complement integer with a minimum value of `-2^31` and a maximum value of `2^31 - 1`. Example: `65`.

* **Long**: 64-bit signed two’s complement integer with a minimum value of `-2^63 + 1` and a maximum value of `2^63 - 1`. Example: `9223372036854775807`, `-9223372036854775807`.

* **Double**: 64-bit inexact, variable-precision with a minimum value of `2^-1074` and a maximum value of `(2-2^-52)·2^1023`. Example: `1.7976931348623157E+308`, `.17976931348623157E+309`, `4.9E-324`.

* **Decimal**: decimal number can be treated as Double, String or ParsingException. This is controlled by `ParsingOptions`. `1.7976931348623157`, `.17976931348623157`.

* **String**: character string which can have escapes. Example: `'this is a string'`, `'this is ''another'' string'`.

* **ColumnReference**: representation of a column field. Unquoted ColumnReference must start with a letter or `_`. Example: `column_name` or `column_name.foo`  or `column_name.foo.bar` or `column_name.0.bar`.

* **All**: representation of all columns. Example: `*`. `column_name.*` is interpreted as `column_name`.

## Reserved Keywords

|      Keyword          |    SQL:2016     |   SQL-92      |
| --------------------- | :-------------: | :-----------: |
| `ALTER`               |     reserved    |   reserved    |
| `AND`                 |     reserved    |   reserved    |
| `AS`                  |     reserved    |   reserved    |
| `BETWEEN`             |     reserved    |   reserved    |
| `BY`                  |     reserved    |   reserved    |
| `CASE`                |     reserved    |   reserved    |
| `CAST`                |     reserved    |   reserved    |
| `CONSTRAINT`          |     reserved    |   reserved    |
| `CREATE`              |     reserved    |   reserved    |
| `CROSS`               |     reserved    |   reserved    |
| `CUBE`                |     reserved    |               |
| `CURRENT_DATE`        |     reserved    |   reserved    |
| `CURRENT_TIME`        |     reserved    |   reserved    |
| `CURRENT_TIMESTAMP`   |     reserved    |   reserved    |
| `CURRENT_USER`        |     reserved    |               |
| `DEALLOCATE`          |     reserved    |   reserved    |
| `DELETE`              |     reserved    |   reserved    |
| `DESCRIBE`            |     reserved    |   reserved    |
| `DISTINCT`            |     reserved    |   reserved    |
| `DROP`                |     reserved    |   reserved    |
| `ELSE`                |     reserved    |   reserved    |
| `END`                 |     reserved    |   reserved    |
| `ESCAPE`              |     reserved    |   reserved    |
| `EXCEPT`              |     reserved    |   reserved    |
| `EXECUTE`             |     reserved    |   reserved    |
| `EXISTS`              |     reserved    |   reserved    |
| `EXTRACT`             |     reserved    |   reserved    |
| `FALSE`               |     reserved    |   reserved    |
| `FOR`                 |     reserved    |   reserved    |
| `FROM`                |     reserved    |   reserved    |
| `FULL`                |     reserved    |   reserved    |
| `GROUP`               |     reserved    |   reserved    |
| `GROUPING`            |     reserved    |               |
| `HAVING`              |     reserved    |   reserved    |
| `IN`                  |     reserved    |   reserved    |
| `INNER`               |     reserved    |   reserved    |
| `INSERT`              |     reserved    |   reserved    |
| `INTERSECT`           |     reserved    |   reserved    |
| `INTO`                |     reserved    |   reserved    |
| `IS`                  |     reserved    |   reserved    |
| `JOIN`                |     reserved    |   reserved    |
| `LEFT`                |     reserved    |   reserved    |
| `LIKE`                |     reserved    |   reserved    |
| `LOCALTIME`           |     reserved    |               |
| `LOCALTIMESTAMP`      |     reserved    |               |
| `NATURAL`             |     reserved    |   reserved    |
| `NORMALIZE`           |     reserved    |               |
| `NOT`                 |     reserved    |   reserved    |
| `NULL`                |     reserved    |   reserved    |
| `ON`                  |     reserved    |   reserved    |
| `OR`                  |     reserved    |   reserved    |
| `ORDER`               |     reserved    |   reserved    |
| `OUTER`               |     reserved    |   reserved    |
| `PREPARE`             |     reserved    |   reserved    |
| `RECURSIVE`           |     reserved    |               |
| `RIGHT`               |     reserved    |   reserved    |
| `ROLLUP`              |     reserved    |               |
| `SELECT`              |     reserved    |   reserved    |
| `TABLE`               |     reserved    |   reserved    |
| `THEN`                |     reserved    |   reserved    |
| `TRUE`                |     reserved    |   reserved    |
| `UESCAPE`             |     reserved    |               |
| `UNION`               |     reserved    |   reserved    |
| `UNNEST`              |     reserved    |               |
| `USING`               |     reserved    |   reserved    |
| `VALUES`              |     reserved    |   reserved    |
| `WHEN`                |     reserved    |   reserved    |
| `WHERE`               |     reserved    |   reserved    |
| `WITH`                |     reserved    |   reserved    |
