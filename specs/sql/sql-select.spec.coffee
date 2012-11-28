h = require('../test-helper')
sql = h.requireSrc('sql')

describe('SqlSelect', () ->
    it('detects expressions as columns', ->
        s = sql.from(['customers', 'C']).select( ["LEN(LastName)", "LenLastName"] )
        h.assertSql(s, "SELECT LEN(LastName) as [LenLastName] FROM [customers] as [C]")
    )

    it('handles two objects ANDed', () ->
        s = sql.from('users')
                .select("login", [ 'zid', 'id' ], [ 'zname', 'name' ])
                .where({ age: 22, name: 'deividy' })
                .and({ test: 123, testing: 1234 })

        exp = "SELECT [users].[login] as [login], [users].[zid] as [id], [users].[zname] as [name] "
        exp += "FROM [users] as [users] "
        exp += "WHERE ([users].[age] = 22 AND [users].[name] = 'deividy' "
        exp += "AND ([users].[test] = 123 AND [users].[testing] = 1234))"

        h.assertSql(s, exp, false)
    )

    it('supports table aliases', () ->
        s = sql.from(['users', 'u'])
                .select("login", [ 'zid', 'id' ], [ 'zname', 'name' ])
                .where({ age: 22, name: 'deividy' })
                .or({ test: 123, testing: 1234 })

        exp = "SELECT [u].[login] as [login], [u].[zid] as [id], [u].[zname] as [name] "
        exp += "FROM [users] as [u] "
        exp += "WHERE (([u].[age] = 22 AND [u].[name] = 'deividy') "
        exp += "OR ([u].[test] = 123 AND [u].[testing] = 1234))"

        h.assertSql(s, exp)
    )

    it('supports JOINS', () ->
        s = sql.from(['users', 'u'])
            .select("login", [ 'zid', 'id' ], [ 'zname', 'name' ])
            .join("messages", { "U.id": sql.name("Messages.UserId")})

        exp = "SELECT [u].[login] as [login], [u].[zid] as [id], [u].[zname] as [name] "
        exp += "FROM [users] as [u] INNER JOIN [messages] as [messages] ON "
        exp += "[U].[id] = [Messages].[UserId]"

        h.assertSql(s, exp, false)
    )

    it('supports ORDER BY and GROUP BY', () ->
        s = sql.from(['users', 'u'])
            .select("login")
            .orderBy('name', 'LEN(LastName)', ["JoinDate", 'DESC'])
            .groupBy('City', 'Foo + Bar')

        exp = "SELECT [u].[login] as [login] FROM [users] as [u] "
        exp += "GROUP BY [0].[City], Foo + Bar "
        exp += "ORDER BY [u].[name] DESC, LEN(LastName) DESC, [u].[JoinDate] DESC"

        h.assertSql(s, exp, false)
    )

    it('can be instantiated via sql.select', () ->
        s = sql.select('FirstName', 'LastName').from('Customers')
        exp = "SELECT [FirstName] as [FirstName], [LastName] as [LastName] FROM [Customers] as [Customers]"

        h.assertSql(s, exp, false)
    )
)
