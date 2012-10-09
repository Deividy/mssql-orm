sqlTokens = require('./sql-tokens')
SqlSelect = require('./sql-select')
_ = require('underscore')

e = _.clone(sqlTokens)

module.exports = _.extend(e, {
    SqlSelect: SqlSelect
    from: (t) -> new SqlSelect(t)
})
