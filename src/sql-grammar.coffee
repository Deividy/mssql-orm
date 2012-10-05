_ = require('underscore')

class SqlToken
    toSql: (formatter) -> return ''

class SqlConditional extends SqlToken
    constructor: (@expr) ->

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

class SqlSelect extends SqlToken
    where: (w) ->
        return @whereClause = new SqlConditional(w)

    having: (c) ->
        return @havingClause = new SqlConditional(c)

module.exports = {
    SqlConditional: SqlConditional
    SqlToken: SqlToken
}
