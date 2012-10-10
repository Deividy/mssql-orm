_ = require("underscore")
{ SqlPredicate, SqlName, SqlFilteredStatement } = sql = require('./sql-tokens')

class SqlDelete extends SqlFilteredStatement
    toSql: (f) ->
        return f.delete(@)

module.exports = SqlDelete
