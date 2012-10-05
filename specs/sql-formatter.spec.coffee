SqlConditional = require('../src/sql-grammar').SqlConditional
SqlOperator = require('../src/sql-operator')

assert = (sqlWhere, expected) ->
    f = new SqlOperator()
    ret = "WHERE #{sqlWhere.toSql(f)}"
    ret.should.eql(expected)

describe('SqlConditional builds SQL WHERE clauses', () ->
    it('handles two objects ANDed', () ->
        sql = new SqlConditional()
        sql.where({ age: 22, name: 'deividy' })
                .and({ test: 123, testing: 1234 })

        exp = "WHERE ((age = 22 AND name = 'deividy')"
        exp += " AND (test = 123 AND testing = 1234))"

        assert(sql, exp)
    )
    
    it('accepts where(object) followed by .or(object) then .and(object)', () ->
        sql = new SqlConditional()
        sql.where({ age: 22, name: 'deividy' })
                .or({ test: 123, testing: 1234 })
                .and({ login: 'root'})

        exp = "WHERE (((age = 22 AND name = 'deividy') OR (test = 123 AND testing = 1234))"
        exp += " AND (login = 'root'))"

        assert(sql, exp)
    )

    it('transforms JS array for column values into SQL IN operator', () ->
        sql = new SqlConditional()

        sql.where({ age: [22, 30, 40] , name: 'deividy' })
        exp = "WHERE (age IN (22, 30, 40) AND name = 'deividy')"

        assert(sql, exp)
    )

    it('supports ad-hoc SQL operators like >=', () ->
        sql = new SqlConditional()

        sql.where({ age: { '>=': 18 } , name: 'deividy' })
        exp = "WHERE (age >= 18 AND name = 'deividy')"

        assert(sql, exp)
    )

    it('supports SQL BETWEEN operator', () ->
        sql = new SqlConditional()

        sql.where({ age: { 'between': [18, 23] } , name: 'deividy' })
        exp = "WHERE (age BETWEEN 18 AND 23 AND name = 'deividy')"

        assert(sql, exp)
    )

    it('supports multiple operators for a single column, plus .or() and .and()', () ->
        sql = new SqlConditional()
        sql.where({ age: { ">": 18, "<": 25 }, name: 'deividy' })
                .or({ test: { "between": [18,25] }, testing: 1234 })
                .and({ login: 'root'})

        exp = "WHERE (((age > 18 AND age < 25 AND name = 'deividy') "
        exp += "OR (test BETWEEN 18 AND 25 AND testing = 1234)) "
        exp += "AND (login = 'root'))"

        assert(sql, exp)
    )

    it('ORs conditions passed in an array', () ->
        sql = new SqlConditional()

        sql.where([{ age: 22, name: 'deividy' }, { age: 18, login: 'deividy' }])
        exp = "WHERE ((age = 22 AND name = 'deividy') OR (age = 18 AND login = 'deividy'))"

        assert(sql, exp)
    )

    it('can AND together two OR groups, and use parens appropriately', () ->
        sql = new SqlConditional()

        sql.where([{ age: 22, name: 'deividy' }, { age: 18, login: 'deividy' }])
            .and([{ login: 'test', pass: 12 }, { login: 'test123', pass: 123 } ])

        exp = "WHERE (((age = 22 AND name = 'deividy') OR (age = 18 AND login = 'deividy')) "
        exp += "AND ((login = 'test' AND pass = 12) OR (login = 'test123' AND pass = 123)))"
        assert(sql, exp)
    )

    it('accepts raw SQL and can .and() it with another clause', () ->
        sql = new SqlConditional()
        sql.where("id = 1 AND test = 2")
            .and({ name: 'test' })

        exp = "WHERE ((id = 1 AND test = 2) AND (name = 'test'))"
        assert(sql, exp)
    )

    it('accepts raw SQL followed by .and() then .or()', () ->
        sql = new SqlConditional()
        sql.where("id = 1 AND test = 2")
            .and({ name: 'test' })
            .or("login = 'test'")

        exp = "WHERE (((id = 1 AND test = 2) AND (name = 'test')) OR (login = 'test'))"
        assert(sql, exp)
    )

    it('protects against SQL injections', () ->
        sql = new SqlConditional()
        sql.where({ login: "HAX0R '-- SELECT * FROM users" })

        exp = "WHERE (login = 'HAX0R ''-- SELECT * FROM users')"
        assert(sql, exp)
    )
   

)
