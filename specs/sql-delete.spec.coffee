{ SqlDelete } = sql = require('../src/db/dialects/sql-grammar')
SqlFormatter = require('../src/db/dialects/base-formatter')


f = new SqlFormatter()
debug = false

describe('SqlDelete', () ->
    it('can be instantiated', ->
        sql.delete("MyTable")
    )
)
