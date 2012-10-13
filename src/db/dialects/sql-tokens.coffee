_ = require('underscore')

<<<<<<< HEAD
class SqlToken
    @nameOrExpr: (s) ->
        # MUST: implement some sort of indexOfAny and test against more operators
        if _.contains(s, '*') || _.contains(s, '+')
            return new SqlExpression(s)

        return new SqlName(s)

    toSql: () -> ''

class SqlVerbatim
    constructor: (@s) ->
    toSql: -> @s

class SqlExpression extends SqlVerbatim
    constructor: (@s) ->
=======
sql = {
    rgxExpression: /[()\+\*\-/]/

    nameOrExpr: (s, prefixHint) ->
        return s if s instanceof SqlToken
        if sql.rgxExpression.test(s) then sql.expr(s) else sql.name(s, prefixHint)

    verbatim: (s) -> new SqlVerbatim(s)
    predicate: (p...) -> new SqlPredicate(p)

    name: (n, prefixHint) ->
        return n if n instanceof SqlToken
        return new SqlMultiPartName(n) if _.isArray(n)
        return new SqlName(n, prefixHint)

    expr: (e) -> new SqlExpression(e)
    and: (terms...) -> new SqlAnd(_.map(terms, SqlPredicate.wrap))
    or: (terms...) -> new SqlOr(_.map(terms, SqlPredicate.wrap))
}

class SqlToken
    cascade: (fn) ->
        return if fn(@) == false

        children = @getChildren()
        return unless children

        for c in children
            if (c instanceof SqlToken)
                c.cascade(fn)
            else
                fn(c)

    getChildren: (fn) -> null
>>>>>>> gustavo

    toSql: () -> ''

class SqlVerbatim extends SqlToken
    constructor: (@s) ->
    toSql: -> @s

<<<<<<< HEAD
class SqlIdentifierGuess extends SqlIdentifier
    constructor: (@given, @guessTable) ->
=======
class SqlExpression extends SqlVerbatim
    constructor: (@s) ->

class SqlLiteral extends SqlToken
    constructor: (@l) ->
    toSql: (f) -> f.literal(@l)
>>>>>>> gustavo

class SqlName extends SqlToken
    constructor: (@name, @prefixHint) ->
    toSql: (f) -> f.name(@)

class SqlMultiPartName extends SqlToken
    constructor: (@parts) ->
    toSql: (f) -> f.multiPartName(@)

class SqlParens extends SqlToken
    constructor: (@contents) ->
    getChildren: -> [@contents]
    toSql: (f) -> f.parens(@contents)

class SqlRelop extends SqlToken
    @pushRelops: (left, right, relops = []) ->
        if _.isString(left)
            left = sql.nameOrExpr(left)

        if _.isArray(right)
            relops.push(new SqlRelop(left, 'IN', right))
        else if _.isObject(right) && !(right instanceof SqlToken)
            for op, operand of right
                relops.push(new SqlRelop(left, op, operand))
        else
            relops.push(new SqlRelop(left, '=', right))

    constructor: (@left, @op, @right) ->
    getChildren: -> [@left, @right]
    toSql: (f) -> f.relop(@left, @op, @right)

class SqlName extends SqlToken
    constructor: (@n, @prefixHint) ->
    toSql: (f) -> f.name(@)

class SqlMultiPartName extends SqlToken
    constructor: (@parts) ->
    toSql: (f) -> f.multiPartName(@)

class SqlParens extends SqlToken
    constructor: (@contents) ->
    toSql: (f) -> f.parens(@contents)

class SqlRelop extends SqlToken
    @build: (left, right) ->
        if _.isString(left)
            left = SqlToken.nameOrExpr(left)

        if _.isArray(v)
            return new [SqlIn(left, right)]
        else if _.isObject(right) && !(right instanceof SqlToken)
            return (
                new SqlRelop(left, operand, op) for op, operand of right
            )
        else
            return new [SqlEquals(left, right)]

    constructor: (@left, @right, @op) ->
    toSql: (f) -> f.relop(@)

class SqlIn extends SqlRelop
    constructor: (@left, @right) ->
    toSql: (f) -> f.in(@)

class SqlEquals extends SqlRelop
    constructor: (@left, @right) ->
    toSql: (f) -> f.equals(@left, @right)

class SqlPredicate extends SqlToken
<<<<<<< HEAD
    @wrap: (arg) ->
        if arg instanceof SqlPredicate
            return arg

        if _.isString(arg)
            return new SqlPredicate(new SqlParens(new SqlVerbatim(arg)))

        if _.isObject(arg)
            relops = []

            for k, v of arg
                relops.concat(SqlRelop.build(k, v))
        if _.isArray(arg)
            terms = (SqlPredicate.wrap(t) for t in arg)

    constructor: (@expr) ->


    and: (w) ->
        # SHOULD: Validate arguments
        @expr = new SqlAnd(@expr, w)
        return @
=======
    @wrap: (term) ->
        if term instanceof SqlToken
            return term

        if _.isString(term)
            return new SqlParens(new SqlVerbatim(term))

        pieces = []

        if _.isArray(term)
            SqlRelop.pushRelops(term[0], term[1], pieces)
        else if _.isObject(term)
            for k, v of term
                SqlRelop.pushRelops(k, v, pieces)

        if (pieces.length > 0)
            return if pieces.length == 1 then pieces[0] else new SqlAnd(pieces)

        throw new Error("Unsupported predicate term: " + t.toString())

    @addOrCreate: (predicate, terms) ->
        if predicate?
            predicate.and(terms...)
        else
            predicate = new SqlPredicate(terms)

        return predicate

    constructor: (terms) ->
        if (terms.length > 1)
            @expr = sql.and(terms...)
        else
            @expr = SqlPredicate.wrap(terms[0])

    append: (terms, connector) ->
        if !(@expr instanceof connector)
            @expr = new connector([@expr])

        for t in terms
            @expr.terms.push(SqlPredicate.wrap(t))
>>>>>>> gustavo

        return @

    and: (terms...) -> @append(terms, SqlAnd)
    or: (terms...) -> @append(terms, SqlOr)

    getChildren: -> [@expr]
    toSql: (f) -> @expr.toSql(f)

class SqlBooleanOp extends SqlToken
    constructor: (@terms) ->
    getChildren: () -> @terms

class SqlAnd extends SqlBooleanOp
    toSql: (formatter) -> formatter.and(@terms)

class SqlOr extends SqlBooleanOp
    toSql: (formatter) -> formatter.or(@terms)

<<<<<<< HEAD
class SqlLiteral extends SqlToken
    constructor: (@l) ->
    toSql: (f) -> f.literal(@l)

module.exports = {
    SqlPredicate: SqlPredicate
    SqlToken: SqlToken
    SqlIdentifier: SqlIdentifier
    SqlIdentifierGuess: SqlIdentifierGuess
    SqlName: SqlName
    SqlMultiPartName: SqlMultiPartName
}
=======
class SqlStatement extends SqlToken
    constructor: (table) ->
        @targetTable = sql.name(table)
        @init()

    init: () ->

class SqlFilteredStatement extends SqlStatement
    where: (terms...) ->
        @whereClause = SqlPredicate.addOrCreate(@whereClause, terms)
        return @

    and: (terms...) ->
        return @where(terms...) unless @whereClause

        @whereClause.and(terms...)
        return @

    or: (terms...) ->
        return @where(sql.or(terms...)) unless @whereClause

        @whereClause.or(terms...)
        return @
        
module.exports = sql
_.extend(sql, {
    SqlToken: SqlToken
    SqlExpression: SqlExpression
    SqlName: SqlName
    SqlMultiPartName: SqlMultiPartName
    SqlPredicate: SqlPredicate
    SqlAnd: SqlAnd
    SqlOr: SqlOr
    SqlStatement: SqlStatement
    SqlFilteredStatement: SqlFilteredStatement
})

require('./sql-update')
>>>>>>> gustavo
