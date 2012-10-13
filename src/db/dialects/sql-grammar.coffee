sqlTokens = require('./sql-tokens')
SqlSelect = require('./sql-select')
SqlInsert = require('./sql-insert')
SqlUpdate = require('./sql-update')
SqlDelete = require('./sql-delete')

_ = require('underscore')

e = _.clone(sqlTokens)

module.exports = _.extend(e, {
    SqlSelect: SqlSelect
    SqlInsert: SqlInsert
    SqlUpdate: SqlUpdate
    SqlDelete: SqlDelete

    from: (t) -> new SqlSelect(t)
<<<<<<< HEAD
    verbatim: (s) -> new sqlTokens.SqlVerbatim(s)
    predicate: (p) -> new sqlTokens.SqlPredicate(p)
    name: (n) -> new sqlTokens.SqlName(n)
    multiPartName: (parts) -> new sqlTokens.MultiPartName(parts)
}
=======
    insert: (t) -> new SqlInsert(t)
    update: (t) -> new SqlUpdate(t)
    delete: (t) -> new SqlDelete(t)
})
>>>>>>> gustavo
