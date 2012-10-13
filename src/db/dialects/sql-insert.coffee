_ = require("underscore")
{ SqlPredicate, SqlName, SqlStatement, SqlData } = sql = require('./sql-tokens')

class SqlInsert extends SqlStatement
    toSql: (f) ->
        return f.insert(@)

    data: (d) ->
        @insertData = [] if (!@insertData?)
        @insertData.push(new SqlData(d))
        return @

module.exports = SqlInsert
