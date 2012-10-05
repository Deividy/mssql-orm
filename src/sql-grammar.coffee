_ = require('underscore')

class SqlToken
    toSql: (formatter) -> return ''

class SqlPredicate extends SqlToken
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

class SqlAnd extends SqlPredicate
    constructor: (@a, @b) ->

    toSql: (formatter) ->
        return formatter.and(@a, @b)

class SqlOr extends SqlPredicate
    constructor: (@a, @b) ->

    toSql: (formatter) ->
        return formatter.or(@a, @b)

class SqlSelect extends SqlToken
    constructor: ->
        @columns = []
        @tables = []

    select: (columnList) ->
        # MUST: decide what to accept in column list (multiple args? array? anything?)
        return @

    distinct: () ->
        @quantifier = "DISTINCT"
        return @

    all: () ->
        @quantifier = "ALL"
        return @

    skip: (n) ->
        @cntSkip = n
        return @

    take: (n) ->
        @cntTake = n
        return @

    from: (table) ->
        @tables.push(table)
        return @

    join: (joinedTable) ->
        # MUST: implement
        return @

    where: (w) ->
        @lastConditional = @whereClause = new SqlPredicate(w)
        return @

    groupBy: (column) ->
        (@groupByColumns ?= []).push(column)
        return @

    having: (c) ->
        @lastConditional = @havingClause = new SqlPredicate(c)
        return @

    orderBy: (o) ->
        # MUST: implement
        return @

    and: (c) ->
        @lastConditional.and(c)
        return @

    or: (c) ->
        @lastConditional.or(c)
        return @

p = SqlSelect.prototype
p.limit = p.top = p.take

module.exports = {
    SqlPredicate: SqlPredicate
    SqlToken: SqlToken
}
