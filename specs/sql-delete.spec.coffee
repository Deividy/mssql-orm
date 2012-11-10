{ SqlDelete } = sql = require('../src/sql')
SqlFormatter = require('../src/sql-formatter')

h = require('./test-helper')

describe('SqlDelete', () ->
    it('works for a basic statement', ->
        h.assert(sql.delete("MyTable"), 'DELETE FROM [MyTable]', false)
    )

    it('supports where clauses', ->
        s = sql.delete('MyTable').where({ date: { '<': '2010-01-01'} })
        h.assert(s, "DELETE FROM [MyTable] WHERE [date] < '2010-01-01'")
    )
)
