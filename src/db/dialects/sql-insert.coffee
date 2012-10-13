_ = require("underscore")
{ SqlPredicate, SqlName, SqlStatement } = sql = require('./sql-tokens')

class SqlInsert extends SqlStatement
    toSql: (f) ->
        return f.insert(@)

    data: (d) ->
        return @

module.exports = SqlInsert
