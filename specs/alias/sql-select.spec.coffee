h = require('../test-helper')
sql = h.requireSrc('sql')
SqlFormatter = h.requireSrc('dialects/sql-formatter')

describe('SqlSelect with aliased schema', () ->
    it('Handles basic SELECT', ->
        s = sql.select('FirstName').from('Customers')
        expected = "SELECT [zCustomerFirstName] as [FirstName] FROM " +
            "[tblCustomers] as [Customers]"
        h.assertAlias(s, expected)
    )
)
