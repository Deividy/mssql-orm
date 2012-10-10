{ SqlUpdate } = sql = require('../src/db/dialects/sql-grammar')
SqlFormatter = require('../src/db/dialects/base-formatter')

h = require('./test-helper')

describe('SqlUpdate', () ->
    it('works for a basic statement', ->
        h.assert(sql.update("MyTable"), 'UPDATE [MyTable]', false)
    )
)
