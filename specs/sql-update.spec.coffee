{ SqlUpdate } = sql = require('../src/db/dialects/sql')
SqlFormatter = require('../src/db/dialects/base-formatter')

h = require('./test-helper')

describe('SqlUpdate', () ->
    it('works for a basic statement', ->

        u = sql.update("MyTable").set({ name: 'Gonzo' }).where({id: 10})
        h.assert(u, "UPDATE [MyTable] SET [name] = 'Gonzo' WHERE [id] = 10", false)
    )
)
