_ = require("underscore")
{ SqlPredicate, SqlName, SqlStatement, SqlToken } = sql = require('./index')

class SqlAliasedExpression extends SqlToken
    constructor: (a) ->
        if _.isString(a)
            @expr = @alias = a
        else if _.isArray(a)
            [@expr, @alias] = a
        else
            @expr = a

class SqlColumn extends SqlAliasedExpression
    constructor: (a) ->
        super(a)
        @expr = sql.nameOrExpr(@expr)

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

class SqlOrdering extends SqlFrom
    constructor: (expr, direction) ->
        @expr = sql.nameOrExpr(expr)
        @direction = if direction = 'DESC' then 'DESC' else 'ASC'

    toSql: (f) -> f.ordering(@)

class SqlSelect extends SqlStatement
    constructor: (tableList...) ->
        @columns = []
        @tables = []
        @joins = []

        (@from(t) for t in tableList)

    addFrom: (table, a) -> a.push(table)

    select: (columns...) ->
        for c in columns
            @columns.push(new SqlColumn(c))

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

    groupBy: (exprs...) ->
        @groupings ?= []

        @groupings.push( (_.map(exprs, sql.nameOrExpr))... )
        return @

    having: (terms...) ->
        @havingClause = @addTerms(@havingClause, terms)
        return @

    addTerms: (predicate, terms) ->
        @lastPredicate = SqlPredicate.addOrCreate(predicate, terms)
        return @lastPredicate

    orderBy: (exprs...) ->
        @orderings ?= []
        for e in exprs
            if _.isArray(e)
                o = new SqlOrdering(e[0], e[1])
            else
                o = new SqlOrdering(e, null)

            @orderings.push(o)
        return @

    and: (terms...) ->
        return @where(terms...) unless @lastPredicate

        @lastPredicate.and(terms...)
        return @

    or: (terms...) ->
        return @where(sql.or(terms...)) unless @lastPredicate
        @lastPredicate.or(terms...)
        return @

    toSql: (f) ->
        return f.select(@)

p = SqlSelect.prototype
p.limit = p.top = p.take

_.extend(sql, {
    select: (t...) ->
        s = new SqlSelect()
        s.select(t...)
    
    from: (t) -> new SqlSelect(t)

    SqlSelect: SqlSelect
})

module.exports = SqlSelect
