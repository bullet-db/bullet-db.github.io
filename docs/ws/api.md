# Bullet API

This section gives a comprehensive overview of the Web Service API for launching Bullet queries.

For examples of queries, see the [examples page](examples.md).

BQL is the interface that is exposed to users to query Bullet. BQL queries that are received by the Web Service are converted to an underlying querying format before being sent to the backend. This conversion is done in the web service using [the bullet-bql library](../releases/#bullet-bql).

## Overview

Bullet-BQL provides users with a friendly SQL-like API to submit queries to the Web Service.

## Statement Syntax

    SELECT select
    FROM stream
    ( WHERE expression )?
    ( GROUP BY expression ( , expression )* )?
    ( HAVING expression )?
    ( ORDER BY orderBy )?
    ( WINDOWING window )?
    ( LIMIT Integer )?
    ';'?

where `select` is

    DISTINCT? selectItem ( , selectItem )*

and `selectItem` is one of

    expression ( AS? identifier )?
    *

and `expression` is one of

    valueExpression                                                                         
    fieldExpression                                                                         
    listExpression                                                                          
    expression IS NULL                                                                      
    expression IS NOT NULL                                                                  
    unaryExpression                                                                         
    functionExpression                                                                      
    expression NOT? IN expression                                    
    expression RLIKE ANY? expression                                 
    expression ( * | / ) expression                                  
    expression ( + | - ) expression                                      
    expression ( < | <= | > | >= ) ( ANY | ALL )? expression         
    expression ( = | != ) ( ANY | ALL )? expression                    
    expression AND expression                                                 
    expression XOR expression                                                 
    expression OR expression                                                  
    ( expression )                                                                      

where `valueExpression` is one of Null, Boolean, Integer, Long, Float, Double, or String

and `fieldExpression` is one of

    identifier ( : fieldType )?
    identifier [ Integer ] ( : fieldType )?
    identifier [ Integer ] . identifier ( : fieldType )?
    identifier . identifier ( : fieldType )?
    identifier . identifier . identifier ( : fieldType )?

`fieldType` is one of

    primitiveType
    LIST [ primitiveType ]
    MAP [ primitiveType ]
    LIST [ MAP [ primitiveType ] ]
    MAP [ MAP [ primitiveType ] ]

and `primitiveType` is `INTEGER`, `LONG`, `FLOAT`, `DOUBLE`, `BOOLEAN`, or `STRING`

where `listExpression` is one of

    []
    [ expression ( , expression )* ]

`unaryExpression` is

    ( NOT | SIZEOF ) ( expression )                                                 with optional parentheses

`functionExpression` is one of

    ( SIZEIS | CONTAINSKEY | CONTAINSVALUE | FILTER ) ( expression, expression )      
    IF ( expression ( , expression )* )                                             three arguments                         
    aggregateExpression                               
    CAST ( expression AS primitiveType )          

where `aggregateExpression` is one of

    COUNT ( * )                                                    
    ( SUM | AVG | MIN | MAX ) ( expression )                                
    COUNT ( DISTINCT expression ( , expression )* )                                           
    distributionType ( expression, inputMode )                            
    TOP ( Integer ( , Integer )?, expression ( , expression )* )

where `distributionType` is `QUANTILE`, `FREQ`, or `CUMFREQ`

and `inputMode` is one of

    LINEAR, Integer                                                                 evenly spaced
    REGION, Number, Number, Number                                                  evenly spaced in a region
    MANUAL, Number ( , Number )*                                                    defined points


and `stream` is one of

    STREAM()                                                                        default time duration will be set from BQLConfig
    STREAM( ( Integer | MAX ), TIME )                                               time based duration control

`RECORD` will be supported in the future.

and `orderBy` is

    expression ( ASC | DESC )? ( , expression ( ASC | DESC )? )*

and `window` is one of

    EVERY ( Integer, ( TIME | RECORD ), include )
    TUMBLING ( Integer, ( TIME | RECORD ) )

`include` is one of

    ALL
    FIRST, Integer, ( TIME | RECORD )


## Data Types

* **Null**: `NULL`.

* **Boolean**: `TRUE`, `FALSE`.

* **Integer**: 32-bit signed two’s complement integer with a minimum value of `-2^31` and a maximum value of `2^31 - 1`. Example: `65`.

* **Long**: 64-bit signed two’s complement integer with a minimum value of `-2^63 + 1` and a maximum value of `2^63 - 1`. Example: `9223372036854775807`, `-9223372036854775807`.

* **Float**: 32-bit inexact, variable-precision with a minimum value of `2^-149` and a maximum value of `(2-2^-23)·2^127`. Example: `1.70141183E+38`, `1.17549435E-38`, `0.15625`.

* **Double**: 64-bit inexact, variable-precision with a minimum value of `2^-1074` and a maximum value of `(2-2^-52)·2^1023`. Example: `1.7976931348623157E+308`, `.17976931348623157E+309`, `4.9E-324`.

* **String**: character string which can have escapes. Example: `'this is a string'`, `'this is ''another'' string'`.

* **Identifier**: representation of a field. Unquoted identifier must start with a letter or `_`. Example: `column_name`, `column_name.foo`, `column_name.foo.bar`, `column_name[0].bar`, or `"123column"`.

* **All**: representation of all fields. Example: `*`.
