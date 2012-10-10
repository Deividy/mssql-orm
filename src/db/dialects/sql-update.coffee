_ = require("underscore")
{ SqlPredicate, SqlName, SqlFilteredStatement } = sql = require('./sql-tokens')

class SqlUpdate extends SqlFilteredStatement
    toSql: (f) ->
        return f.update(@)

module.exports = SqlUpdate
