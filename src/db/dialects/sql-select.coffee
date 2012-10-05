_ = require("underscore")
{ SqlPredicate, SqlIdentifierGuess } = require('./sql-tokens')

class SqlSelect
    constructor: (t) ->
        @columns = []
        @tables = []

        @addTable(t)

    addAlias: (o, a) ->
        r = o if (_.isArray(o))
        r = [ o, o ] if (_.isString(o))
        r = [ o ]

        if (_.isString(r[0]))
            r[0] = new SqlIdentifierGuess(r[0])

        a.push(r)

        return r

    addTable: (t) ->
        table = @addAlias(t, @tables)
        @lastAlias = table[1] if (table[1])

    select: (columns...) ->
        for c in columns
            col = @addAlias(c, @columns)
            col[0].guessTable = @lastAlias

            @columns.push(col)

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
        @whereClause = new SqlPredicate(w)
        @lastPredicate = @whereClause
        return @

    groupBy: (column) ->
        (@groupByColumns ?= []).push(column)
        return @

    having: (c) ->
        @havingClause = new SqlPredicate(c)
        @lastPredicate = @havingClause
        return @

    orderBy: (o) ->
        # MUST: implement
        return @

    and: (c) ->
        @lastPredicate.and(c)
        return @

    or: (c) ->
        @lastPredicate.or(c)
        return @

    toSql: (f) ->
        return f.select(@)

p = SqlSelect.prototype
p.limit = p.top = p.take

module.exports = SqlSelect