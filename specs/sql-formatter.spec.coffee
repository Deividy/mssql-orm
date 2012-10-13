sql = require('../src/db/dialects/sql-grammar')
SqlFormatter = require('../src/db/dialects/base-formatter')

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

        noHint = sql.name("Users")
        noHint.toSql(f).should.eql("[Users]")

        withHint = sql.name("Name", "U")
        withHint.toSql(f).should.eql("[U].[Name]")

        overridenHint = sql.name("O.Name", "U")
        overridenHint.toSql(f).should.eql("[O].[Name]")
    )
)
