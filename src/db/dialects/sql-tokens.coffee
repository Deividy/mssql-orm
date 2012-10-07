class SqlToken
    toSql: () -> ''

class SqlVerbatim
    constructor: (@s) ->
    toSql: -> @s

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

class SqlPredicate extends SqlToken
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
