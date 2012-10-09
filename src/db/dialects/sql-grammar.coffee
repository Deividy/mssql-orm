SqlSelect = require('./sql-select')
sqlTokens = require('./sql-tokens')

module.exports = {
    SqlPredicate: sqlTokens.SqlPredicate
    SqlToken: sqlTokens.SqlToken
    SqlExpression: sqlTokens.SqlExpression
    SqlSelect: SqlSelect

    from: (t) -> new SqlSelect(t)
    verbatim: (s) -> new sqlTokens.SqlVerbatim(s)
    predicate: (p) -> new sqlTokens.SqlPredicate(p)
    name: (n) -> new sqlTokens.SqlName(n)
    multiPartName: (parts) -> new sqlTokens.MultiPartName(parts)
    expr: (e) -> new sqlTokens.SqlExpression(e)
}
