{ SqlUpdate } = sql = require('../src/db/dialects/sql-grammar')
SqlFormatter = require('../src/db/dialects/base-formatter')


f = new SqlFormatter()
debug = false

describe('SqlUpdate', () ->
    it('can be instantiated', ->
        sql.update("MyTable")
    )
)
