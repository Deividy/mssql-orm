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

<<<<<<< HEAD
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
=======
class SqlColumn extends SqlAliasedExpression
    constructor: (a, prefixHint) ->
        super(a)
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

class SqlOrdering extends SqlFrom
    constructor: (expr, direction, tableHint) ->
        @expr = sql.nameOrExpr(expr, tableHint)
        @direction = if direction = 'DESC' then 'DESC' else 'ASC'

    toSql: (f) -> f.ordering(@)

class SqlSelect extends SqlStatement
    constructor: (tableList...) ->
        @columns = []
        @tables = []
        @joins = []
>>>>>>> gustavo

        (@from(t) for t in tableList)

<<<<<<< HEAD
    addTable: (t) ->
        table = @addAlias(t, @tables)
        @lastAlias = if (table[1]?) then table[1] else table[0]

    select: (columns...) ->
        for c in columns
            col = @addAlias(c)
            col[0].guessTable = @lastAlias
            @columns.push(col)
=======
    addFrom: (table, a) ->
        a.push(table)
        @tableHint = table.alias || @tableHint

    select: (columns...) ->
        for c in columns
            @columns.push(new SqlColumn(c, @tableHint))
>>>>>>> gustavo

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
<<<<<<< HEAD
        @addTable(table)
        return @

    join: (joinedTable) ->
        # joinedTable = { type: "LEFT", table: SqlSelect }
        @joins.push(joinedTable)
        return @

    where: (w) ->
        i = new SqlIdentifierGuess(w, @lastAlias)
        if (!@whereClause?) 
            @lastPredicate = @whereClause = new SqlPredicate(i) 
        else 
            @lastPredicate = @whereClause.and(i)
        
=======
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
>>>>>>> gustavo
        return @

    having: (terms...) ->
        @havingClause = @addTerms(@havingClause, terms)
        return @

<<<<<<< HEAD
    having: (c) ->
        i = new SqlIdentifierGuess(c, @lastAlias)
        if (!@havingClause?) 
            @lastPredicate = @havingClause = new SqlPredicate(i) 
        else 
            @lastPredicate = @havingClause.and(i)
        return @
=======
    addTerms: (predicate, terms) ->
        @lastPredicate = SqlPredicate.addOrCreate(predicate, terms)
        @fillTableHints()
        return @lastPredicate
>>>>>>> gustavo

    orderBy: (exprs...) ->
        @orderings ?= []
        for e in exprs
            if _.isArray(e)
                o = new SqlOrdering(e[0], e[1], @tableHint)
            else
                o = new SqlOrdering(e, null, @tableHint)

            @orderings.push(o)
        return @

<<<<<<< HEAD
    and: (c) ->
        i = new SqlIdentifierGuess(c, @lastAlias)
        @lastPredicate.and(i)
        return @

    or: (c) ->
        i = new SqlIdentifierGuess(c, @lastAlias)
        @lastPredicate.or(i)
=======
    and: (terms...) ->
        return @where(terms...) unless @lastPredicate

        @lastPredicate.and(terms...)
        @fillTableHints()
        return @

    or: (terms...) ->
        return @where(sql.or(terms...)) unless @lastPredicate

        @lastPredicate.or(terms...)
        @fillTableHints()
>>>>>>> gustavo
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
