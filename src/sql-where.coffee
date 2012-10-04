_ = require('underscore')

class SqlToken
    constructor: (@t) ->

    toSql: (formatter) ->
        return formatter.expression(@t)

class SqlAnd extends SqlToken
    constructor: (@a, @b) ->

    toSql: (formatter) ->
        return formatter.and(@a, @b)

class SqlOr extends SqlToken
    constructor: (@a, @b) ->

    toSql: (formatter) ->
        return formatter.or(@a, @b)

class SqlWhere extends SqlToken
    constructor: () ->

    where: (w) ->
        @expr = w if (w)
        return @

    and: (w) ->
        # SHOULD: Validate arguments
        throw new Error("SqlExpression.and() requires a where clause") if (!w)

        @expr = new SqlAnd(@expr, w)
        return @

    or: (w) ->
         # SHOULD: Validate arguments
        throw new Error("SqlExpression.or() requires a where clause") if (!w)

        @expr = new SqlOr(@expr, w)
        return @

    toSql: (formatter) ->
        formatter.where(@expr)

module.exports = {
    SqlWhere: SqlWhere
    SqlToken: SqlToken
}