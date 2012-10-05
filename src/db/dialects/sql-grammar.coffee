SqlSelect = require('./sql-select')
sqlTokens = require('./sql-tokens')

module.exports = {
    SqlPredicate: sqlTokens.SqlPredicate
    SqlToken: sqlTokens.SqlPredicate
    SqlSelect: SqlSelect

    from: (t) -> new SqlSelect(t)

}