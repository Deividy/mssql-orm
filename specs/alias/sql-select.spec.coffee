h = require('../test-helper')
sql = h.requireSrc('sql')
SqlFormatter = h.requireSrc('dialects/sql-formatter')

describe('SqlSelect with aliased schema', () ->
    it('Handles basic SELECT', ->
        s = sql.select('CustomerId', 'CustomerFirstName').from('customer')
        expected = "SELECT [id] as [CustomerId], [FirstName] as [CustomerFirstName] FROM " +
            "[Customers] as [customer]"
        h.assertAlias(s, expected)
    )
)
