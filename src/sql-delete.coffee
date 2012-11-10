_ = require("underscore")
{ SqlPredicate, SqlName, SqlFilteredStatement } = sql = require('./sql')

class SqlDelete extends SqlFilteredStatement
    toSql: (f) ->
        return f.delete(@)


_.extend(sql, {
    delete: (t) -> new SqlDelete(t)
    SqlDelete: SqlDelete
})

module.exports = SqlDelete
