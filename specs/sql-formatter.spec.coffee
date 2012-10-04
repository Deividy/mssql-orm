SqlConditional = require('../src/sql-grammar').SqlConditional
SqlFormatter = require('../src/sql-formatter')

assert = (sqlWhere, expected) ->
    f = new SqlFormatter()
    console.log(sqlWhere.toSql(f))
    sqlWhere.toSql(f).should.eql(expected)

describe('SqlExpression builds SQL WHERE clauses', () ->
    it('handles two objects ANDed', () ->
        sql = new SqlConditional()
        sql.where({ age: 22, name: 'deividy' })
                .and({ test: 123, testing: 1234 })

        exp = "WHERE ((age = 22 AND name = 'deividy')"
        exp += " AND (test = 123 AND testing = 1234))"

        assert(sql, exp)
    )
    ###
    it('accepts where(object) followed by .or(object) then .and(object)', () ->
        sql = new SqlExpression()
        sql.where({ age: 22, name: 'deividy' })
                .or({ test: 123, testing: 1234 })
                .and({ login: 'root'})

        exp = "where (((age = 22 AND name = 'deividy') OR (test = 123 AND testing = 1234))"
        exp += " AND (login = 'root'))"

        sql.getWhere().should.eql(exp)
    )

    it('transforms JS array for column values into SQL IN operator', () ->
        sql = new SqlExpression()

        sql.where({ age: [22, 30, 40] , name: 'deividy' })
        exp = "where (age IN (22, 30, 40) AND name = 'deividy')"

        sql.getWhere().should.eql(exp)
    )

    it('supports ad-hoc SQL operators like >=', () ->
        sql = new SqlExpression()

        sql.where({ age: { '>=': 18 } , name: 'deividy' })
        exp = "where (age >= 18 AND name = 'deividy')"

        sql.getWhere().should.eql(exp)
    )

    it('supports SQL BETWEEN operator', () ->
        sql = new SqlExpression()

        sql.where({ age: { 'between': [18, 23] } , name: 'deividy' })
        exp = "where (age BETWEEN 18 AND 23 AND name = 'deividy')"

        sql.getWhere().should.eql(exp)
    )

    it('supports multiple operators for a single column, plus .or() and .and()', () ->
        sql = new SqlExpression()
        sql.where({ age: { ">": 18, "<": 25 }, name: 'deividy' })
                .or({ test: { "between": [18,25] }, testing: 1234 })
                .and({ login: 'root'})

        exp = "where (((age > 18 AND age < 25 AND name = 'deividy') "
        exp += "OR (test BETWEEN 18 AND 25 AND testing = 1234)) "
        exp += "AND (login = 'root'))"

        sql.getWhere().should.eql(exp)
    )

    it('ORs conditions passed in an array', () ->
        sql = new SqlExpression()

        sql.where([{ age: 22, name: 'deividy' }, { age: 18, login: 'deividy' }])
        exp = "where ((age = 22 AND name = 'deividy') OR (age = 18 AND login = 'deividy'))"

        sql.getWhere().should.eql(exp)
    )

    it('can AND together two OR groups, and use parens appropriately', () ->
        sql = new SqlExpression()

        sql.where([{ age: 22, name: 'deividy' }, { age: 18, login: 'deividy' }])
            .and([{ login: 'test', pass: 12 }, { login: 'test123', pass: 123 } ])

        exp = "where (((age = 22 AND name = 'deividy') OR (age = 18 AND login = 'deividy')) "
        exp += "AND ((login = 'test' AND pass = 12) OR (login = 'test123' AND pass = 123)))"
        sql.getWhere().should.eql(exp)
    )

    it('accepts raw SQL and can .and() it with another clause', () ->
        sql = new SqlExpression()
        sql.where("id = 1 AND test = 2")
            .and({ name: 'test' })

        exp = "where (id = 1 AND test = 2 AND (name = 'test'))"
        sql.getWhere().should.eql(exp)
    )

    it('accepts raw SQL followed by .and() then .or()', () ->
        sql = new SqlExpression()
        sql.where("id = 1 AND test = 2")
            .and({ name: 'test' })
            .or("login = 'test'")

        exp = "where ((id = 1 AND test = 2 AND (name = 'test')) OR login = 'test')"
        sql.getWhere().should.eql(exp)
    )

    it('protects against SQL injections', () ->
        sql = new SqlExpression()
        sql.where({ login: "HAX0R '-- SELECT * FROM users" })

        exp = "where (login = 'HAX0R ''-- SELECT * FROM users')"
        sql.getWhere().should.eql(exp)
    )
    ###

)
