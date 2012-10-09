_ = require('underscore')

rgxExpression = "*+/-()"

class SqlToken
    @rgxExpression: /[()\+\*\-/]/
    @nameOrExpr: (s) -> if @rgxExpression.test(s) then new SqlExpression(s) else new SqlName(s)
    cascade: (fn) -> fn(@)
    toSql: () -> ''

class SqlVerbatim extends SqlToken
    constructor: (@s) ->
    toSql: -> @s

class SqlExpression extends SqlVerbatim
    constructor: (@s) ->

class SqlName extends SqlToken
    constructor: (@n, @prefixHint) ->
    toSql: (f) -> f.name(@)

class SqlMultiPartName extends SqlToken
    constructor: (@parts) ->
    toSql: (f) -> f.multiPartName(@)

class SqlParens extends SqlToken
    constructor: (@contents) ->

    cascade: (fn) ->
        fn(@)
        @contents.cascade(@)

    toSql: (f) -> f.parens(@contents)

class SqlRelop extends SqlToken
    @pushRelops: (left, right, relops = []) ->
        if _.isString(left)
            left = SqlToken.nameOrExpr(left)

        if _.isArray(right)
            relops.push(new SqlRelop(left, right))
        else if _.isObject(right) && !(right instanceof SqlToken)
            for op, operand of right
                relops.push(new SqlRelop(left, op, operand))
        else
            relops.push(new SqlRelop(left, '=', right))

    constructor: (@left, @op, @right) ->

    cascade: (fn) ->
        fn(@)
        @left.cascade(fn)
        @right.cascasde(fn)

    toSql: (f) -> f.relop(@left, @op, @right)

class SqlPredicate extends SqlToken
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

    constructor: (expr) -> @expr = SqlPredicate.wrap(expr)

    append: (terms, connector) ->
        if !(@expr instanceof connector)
            @expr = new connector([@expr])

        for t in terms
            @expr.terms.push(SqlPredicate.wrap(t))

        return @

    and: (terms...) -> @append(terms, SqlAnd)
    or: (terms...) -> @append(terms, SqlOr)

    cascade: (fn) ->
        fn(@)
        @expr.cascade(fn)

    toSql: (f) -> @expr.toSql(f)

class SqlBooleanOp extends SqlToken
    constructor: (@terms) ->
    cascade: (fn) ->
        fn(@)
        _.each(@terms, fn)

class SqlAnd extends SqlBooleanOp
    toSql: (formatter) -> formatter.and(@terms)

class SqlOr extends SqlBooleanOp
    toSql: (formatter) -> formatter.or(@terms)

class SqlLiteral extends SqlToken
    constructor: (@l) ->
    toSql: (f) -> f.literal(@l)

module.exports = {
    SqlPredicate: SqlPredicate
    SqlExpression: SqlExpression
    SqlToken: SqlToken
    SqlName: SqlName
    SqlMultiPartName: SqlMultiPartName
}
