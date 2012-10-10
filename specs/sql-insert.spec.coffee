{ SqlInsert } = sql = require('../src/db/dialects/sql-grammar')
SqlFormatter = require('../src/db/dialects/base-formatter')


f = new SqlFormatter()
debug = false

describe('SqlInsert', () ->
    it('can be instantiated', ->
        new SqlInsert()
    )
)
