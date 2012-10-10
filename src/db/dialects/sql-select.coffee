_ = require("underscore")
{ SqlPredicate, SqlName, SqlStatement, SqlToken } = sql = require('./sql-tokens')

class SqlAliasedExpression extends SqlToken
    constructor: (a) ->
        if _.isString(a)
            @expr = @alias = a
        else if _.isArray(a)
            [@expr, @alias] = a
        else
            @expr = a

class SqlColumn extends SqlAliasedExpression
    constructor: (a, prefixHint) ->
        super(a)
        if _.isString(@expr)
            @expr = sql.nameOrExpr(@expr, prefixHint)

    toSql: (f) -> f.column(@)

class SqlFrom extends SqlAliasedExpression
    constructor: (a) ->
        super(a)
        if _.isString(@expr)
            @expr = sql.name(@expr)

    toSql: (f) -> f.from(@)

class SqlJoin extends SqlFrom
    constructor: (a, terms) ->
        super(a)
        @predicate = new SqlPredicate(terms)

    toSql: (f) -> f.join(@)

class SqlSelect extends SqlStatement
    constructor: (tableList...) ->
        @columns = []
        @tables = []
        @joins = []

        (@from(t) for t in tableList)

    addFrom: (table, a) ->
        a.push(table)
        @tableHint = table.alias || @tableHint

    select: (columns...) ->
        for c in columns
            @columns.push(new SqlColumn(c, @tableHint))

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
        @addFrom(new SqlFrom(table), @tables)
        return @

    join: (table, terms...) ->
        @lastJoin = new SqlJoin(table, terms)
        @addFrom(@lastJoin, @joins)
        return @

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
