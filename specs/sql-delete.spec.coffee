{ SqlDelete } = sql = require('../src/db/dialects/sql-grammar')
SqlFormatter = require('../src/db/dialects/base-formatter')

h = require('./test-helper')

describe('SqlDelete', () ->
    it('works for a basic statement', ->
        h.assert(sql.delete("MyTable"), 'DELETE FROM [MyTable]', false)
    )
)
