_ = require("underscore")
{ SqlPredicate, SqlName } = sql = require('./sql-tokens')

class SqlSelect
    constructor: (tableList...) ->
        @columns = []
        @tables = []
        @joins = []

        (@addTable(t) for t in tableList)

    addAlias: (o, a) ->
        if (_.isArray(o))
            r = o
        else if (_.isString(o))
            r = [ o, o ]
        else
            r = [ o ]

        if (_.isString(r[0]))
            r[0] = new SqlName(r[0])

        a.push(r) if (a)

        return r

    addTable: (t) ->
        table = @addAlias(t, @tables)
        @lastAlias = table[1] if (table[1])

    select: (columns...) ->
        for c in columns
            col = @addAlias(c)
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
        @joins.push(joinedTable) if (joinedTable instanceof SqlSelect)
        return @

    joinOn: (@jOn...) ->
        ###
            [
                [ 'users', 'users_id', 'msgs_id' ]
            ]
        ###

    joinType: (@jType) ->

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
