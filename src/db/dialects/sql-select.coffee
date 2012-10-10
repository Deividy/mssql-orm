_ = require("underscore")
{ SqlPredicate, SqlName, SqlStatement } = sql = require('./sql-tokens')

class SqlSelect extends SqlStatement
    constructor: (tableList...) ->
        @columns = []
        @tables = []
        @joins = []

        (@addTable(t) for t in tableList)

    addWithAlias: (o, a, prefixHint) ->
        if (_.isArray(o))
            r = o
        else if (_.isString(o))
            r = [ o, o ]
        else
            r = [ o ]

        (r[0] = sql.nameOrExpr(r[0], prefixHint)) if _.isString(r[0])
        a.push(r)
        return r

    addTable: (t) ->
        table = @addWithAlias(t, @tables)
        @tableHint = table[1] if (table[1]?)

    select: (columns...) ->
        for c in columns
            col = @addWithAlias(c, @columns, @tableHint)

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
        @joins.push(joinedTable) if (joinedTable instanceof SqlSelect)
        return @

    joinOn: (@jOn...) ->
        ###
            [
                [ 'users', 'users_id', 'msgs_id' ]
            ]
        ###

    joinType: (@jType) ->

    where: (terms...) ->
        @whereClause = @addTerms(@whereClause, terms)
        return @

    groupBy: (column) ->
        (@groupByColumns ?= []).push(column)
        return @

    having: (terms...) ->
        @havingClause = @addTerms(@havingClause, terms)
        return @

    addTerms: (predicate, terms) ->
        @lastPredicate = SqlPredicate.addOrCreate(predicate, terms)
        @fillTableHints()
        return @lastPredicate

    orderBy: (o) ->
        # MUST: implement
        return @

    and: (terms...) ->
        return @where(terms...) unless @lastPredicate
        @lastPredicate.and(terms...)
        @fillTableHints()
        return @

    or: (terms...) ->
        return @where(sql.or(terms...)) unless @lastPredicate
        @lastPredicate.or(terms...)
        @fillTableHints()
        return @

    fillTableHints: ->
        return unless (hint = @tableHint)
        @lastPredicate.cascade((n) ->
            return false if (n instanceof SqlSelect)
            if (n instanceof SqlName && !n.prefixHint?)
                n.prefixHint = hint
        )

    toSql: (f) ->
        return f.select(@)

p = SqlSelect.prototype
p.limit = p.top = p.take

module.exports = SqlSelect
