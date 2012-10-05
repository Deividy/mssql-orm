_ = require('underscore')

class SqlToken
    toSql: (formatter) -> return ''

class SqlConditional extends SqlToken
    constructor: (@expr) ->

    where: (w) ->
        @expr = w if (w)
        return @

    and: (w) ->
        # SHOULD: Validate arguments
        @expr = new SqlAnd(@expr, w)
        return @

    or: (w) ->
         # SHOULD: Validate arguments
        @expr = new SqlOr(@expr, w)
        return @

    toSql: (formatter) ->
        return formatter.conditional(@expr)

class SqlAnd extends SqlConditional
    constructor: (@a, @b) ->

    toSql: (formatter) ->
        return formatter.and(@a, @b)

class SqlOr extends SqlConditional
    constructor: (@a, @b) ->

    toSql: (formatter) ->
        return formatter.or(@a, @b)

module.exports = {
    SqlConditional: SqlConditional
    SqlToken: SqlToken
}
