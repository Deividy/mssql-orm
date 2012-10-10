_ = require('underscore')

sql = {
    rgxExpression: /[()\+\*\-/]/

    nameOrExpr: (s, prefixHint) ->
        if sql.rgxExpression.test(s) then sql.expr(s) else sql.name(s, prefixHint)

    verbatim: (s) -> new SqlVerbatim(s)
    predicate: (p) -> new SqlPredicate(p)

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

    toSql: () -> ''

class SqlVerbatim extends SqlToken
    constructor: (@s) ->
    toSql: -> @s

class SqlExpression extends SqlVerbatim
    constructor: (@s) ->

class SqlLiteral extends SqlToken
    constructor: (@l) ->
    toSql: (f) -> f.literal(@l)

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

    getChildren: -> [@expr]
    toSql: (f) -> @expr.toSql(f)

class SqlBooleanOp extends SqlToken
    constructor: (@terms) ->
    getChildren: () -> @terms

class SqlAnd extends SqlBooleanOp
    toSql: (formatter) -> formatter.and(@terms)

class SqlOr extends SqlBooleanOp
    toSql: (formatter) -> formatter.or(@terms)

class SqlStatement extends SqlToken
    constructor: (table) ->
        @
        
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
})
