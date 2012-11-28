h = require('../test-helper')
sql = h.requireSrc('sql')
SqlFormatter = h.requireSrc('dialects/sql-formatter')

sys = require('sys')

f = new SqlFormatter()

describe('SqlFormatter', () ->
    it('parses SQL names', ->
        f.parseName("a.b.c").should.eql(['a', 'b', 'c'])
        f.parseName("foo.bar").should.eql(['foo', 'bar'])
        f.parseName("some.Table").should.eql(['some', 'Table'])
    )

    it('Emits SQL names correctly', ->
        multi = sql.name(["Db", "Schema", "Table"])
        multi.toSql(f).should.eql("[Db].[Schema].[Table]")

        noPrefix = sql.name("Users")
        noPrefix.toSql(f).should.eql("[Users]")

        withPrefix = sql.name("O.Name")
        withPrefix.toSql(f).should.eql("[O].[Name]")
    )
)
