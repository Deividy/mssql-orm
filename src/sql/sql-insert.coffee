_ = require("underscore")
{ SqlPredicate, SqlName, SqlStatement } = sql = require('./index')

class SqlInsert extends SqlStatement
    toSql: (f) ->
        return f.insert(@)

_.extend(sql, {
    insert: (t) -> new SqlInsert(t)

    SqlInsert: SqlInsert
})

module.exports = SqlInsert
