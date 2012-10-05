sql = require('../src/db/dialects/sql-grammar')
SqlFormatter = require('../src/db/dialects/base-formatter')


f = new SqlFormatter()

assert = (sqlSelect, expected) ->
    ret = sqlSelect.toSql(f)
    ret.should.eql(expected)

describe('SqlSelect builds select SQL expression', () ->
    it('handles two objects ANDed', () ->
        s = sql.from('users')
                .select("login", [ 'zid', 'id' ], [ 'zname', 'name' ])
                .where({ age: 22, name: 'deividy' })
                .and({ test: 123, testing: 1234 })

        exp = "SELECT [users].[login] as [login], [users].[zid] as [id], [users].[zname] as [name]"
        exp +=  "FROM users "
        exp += "WHERE ((age = 22 AND name = 'deividy') "
        exp += "AND (test = 123 AND testing = 1234))"

        assert(s, exp)
    )

    it('supports table aliases', () ->
        s = sql.from(['users', 'u'])
                .select("login", [ 'zid', 'id' ], [ 'zname', 'name' ])
                .where({ age: 22, name: 'deividy' })
                .or({ test: 123, testing: 1234 })

        exp = "SELECT [u].[login] as [login], [u].[zid] as [id], [u].[zname] as [name] FROM users u "
        exp += "WHERE ((age = 22 AND name = 'deividy')"
        exp += " OR (test = 123 AND testing = 1234))"

        assert(s, exp)
    )
)