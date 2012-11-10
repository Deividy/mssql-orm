{ SqlInsert } = sql = require('../src/sql')
SqlFormatter = require('../src/base-formatter')

h = require('./test-helper')

describe('SqlInsert', () ->
    it('works for a basic statement', ->
        h.assert(sql.insert("MyTable"), 'INSERT [MyTable]', false)
    )
)
