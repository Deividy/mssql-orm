_ = require("underscore")
{ SqlPredicate, SqlIdentifierGuess } = require('./sql-tokens')

class SqlSelect
    constructor: (table) ->
        @columns = []
        @tables = []
        @joins = []

        @addTable(table)

    addAlias: (o, a) ->
        if (_.isArray(o))
            r = o
        else if (_.isString(o))
            r = [ o, o ]
        else
            throw new Error("Format not supported for addAlias #{o.toString()}")

        r[0] = new SqlIdentifierGuess(r[0]) if (_.isString(r[0]))
        a.push(r) if (a)

        return r

    addTable: (t) ->
        table = @addAlias(t, @tables)
        @lastAlias = if (table[1]?) then table[1] else table[0]

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
        @addTable(table)
        return @

    join: (joinedTable) ->
        # joinedTable = { type: "LEFT", table: SqlSelect }
        @joins.push(joinedTable)
        return @

    where: (w) ->
        i = new SqlIdentifierGuess(w, @lastAlias)
        if (!@whereClause?) then @whereClause = new SqlPredicate(i) else @whereClause.and(i)
        return @

    groupBy: (column) ->
        (@groupByColumns ?= []).push(column)
        return @

    having: (c) ->
        @havingClause = new SqlPredicate(c)
        @whereClause = @havingClause
        return @

    orderBy: (o) ->
        # MUST: implement
        return @

    and: (c) ->
        i = new SqlIdentifierGuess(c, @lastAlias)
        @whereClause.and(i)
        return @

    or: (c) ->
        i = new SqlIdentifierGuess(c, @lastAlias)
        @whereClause.or(i)
        return @

    toSql: (f) ->
        return f.select(@)

p = SqlSelect.prototype
p.limit = p.top = p.take

module.exports = SqlSelect
