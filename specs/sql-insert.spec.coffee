{ SqlInsert } = sql = require('../src/db/dialects/sql-grammar')
SqlFormatter = require('../src/db/dialects/base-formatter')

h = require('./test-helper')

describe('SqlInsert', () ->
    it('works for a basic statement', ->
        h.assert(sql.insert("MyTable"), 'INSERT [MyTable]', false)
    )
)
