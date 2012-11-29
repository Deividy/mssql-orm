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

    it('Handles SQL prefixes', ->
        s = sql.select('customer.CustomerId', 'CustomerFirstName').from('customer')
        expected = "SELECT [customer].[id] as [CustomerId], [FirstName] as [CustomerFirstName] FROM " +
            "[Customers] as [customer]"
        h.assertAlias(s, expected)
    )

    it('Handles SELECT with WHERE clause', ->
        s = sql.select('CustomerId', 'CustomerFirstName').from('customer')
            .where({CustomerFirstName: 'Bilbo'})
        expected = "SELECT [id] as [CustomerId], [FirstName] as [CustomerFirstName] FROM " +
            "[Customers] as [customer] WHERE [FirstName] = 'Bilbo'"
        h.assertAlias(s, expected)
    )
)
