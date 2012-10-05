class SqlToken
    toSql: (formatter) -> return ''

class SqlIdentifier extends SqlToken
    constructor: (@columnName) ->

    toSql: (formatter) ->
        formatter.identifier(@)


class SqlIdentifierGuess extends SqlIdentifier
    constructor: (@guessTable, @given) ->

    toSql: (formatter) ->
        formatter.identifierGuess(@)

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

module.exports = {
    SqlPredicate: SqlPredicate
    SqlToken: SqlToken
    SqlIdentifier: SqlIdentifier
    SqlIdentifierGuess: SqlIdentifierGuess
}