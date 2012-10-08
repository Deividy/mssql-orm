_ = require('underscore')

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

class SqlIdentifier extends SqlToken
    constructor: (@columnName) ->

    toSql: (formatter) ->
        formatter.identifier(@)

class SqlIdentifierGuess extends SqlIdentifier
    constructor: (@given, @guessTable) ->

    toSql: (formatter) ->
        formatter.identifierGuess(@)

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
             




        return t.toSql(@) if (t instanceof SqlPredicate)
        return "(#{t})" if (_.isString(t))
        return @predicateArray(t) if (_.isArray(t))
        return @predicateObject(t) if (_.isObject(t))
        throw new Error("Unsupported predicate " + t.toString())

    constructor: (@expr) ->


    and: (w) ->
        # SHOULD: Validate arguments
        @expr = new SqlAnd(@expr, w)
        return @

    or: (w) ->
         # SHOULD: Validate arguments
        @expr = new SqlOr(@expr, w)
        return @

    toSql: (formatter) ->
        return formatter.predicate(@expr)

class SqlAnd extends SqlPredicate
    constructor: (@a, @b) ->

    toSql: (formatter) ->
        return formatter.and(@a, @b)

class SqlOr extends SqlPredicate
    constructor: (@a, @b) ->

    toSql: (formatter) ->
        return formatter.or(@a, @b)

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
