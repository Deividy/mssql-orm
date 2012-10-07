_ = require("underscore")
SqlSelect = require('./sql-select')
sqlTokens = require('./sql-tokens')

module.exports = {
    SqlPredicate: sqlTokens.SqlPredicate
    SqlToken: sqlTokens.SqlPredicate
    SqlSelect: SqlSelect

    from: (table) ->
        return new SqlSelect(table)

}