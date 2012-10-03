SqlExpression = require('../src/sql-expression')

describe('tests with sql-expression', () ->
    it('should return a simple where clause', () ->
        sql = new SqlExpression()
        sql.where({ age: 22, name: 'deividy' })
                .and({ test: 123, testing: 1234 })

        exp = "where (age = 22 AND name = 'deividy')"
        exp += " AND (test = 123 AND testing = 1234)"


        expect(sql.getWhere()).toEqual(exp)
    )

    it('should return a where clause with or', () ->
        sql = new SqlExpression()
        sql.where({ age: 22, name: 'deividy' })
                .or({ test: 123, testing: 1234 })
                .and({ login: 'root'})

        exp = "where (age = 22 AND name = 'deividy') OR (test = 123 AND testing = 1234)"
        exp += " AND (login = 'root')"

        expect(sql.getWhere()).toEqual(exp)
    )

    it('should return a where clause with in, using a array', () ->
        sql = new SqlExpression()

        sql.where({ age: [22, 30, 40] , name: 'deividy' })
        exp = "where age IN (22, 30, 40) AND name = 'deividy'"

        expect(sql.getWhere()).toEqual(exp)
    )

    it('should return a where clause using a opertor', () ->
        sql = new SqlExpression()

        sql.where({ age: { '>=': 18 } , name: 'deividy' })
        exp = "where age >= 18 AND name = 'deividy'"

        expect(sql.getWhere()).toEqual(exp)
    )

    it('should return a where clause with between', () ->
        sql = new SqlExpression()

        sql.where({ age: { 'between': [18, 23] } , name: 'deividy' })
        exp = "where age BETWEEN 18 AND 23 AND name = 'deividy'"

        expect(sql.getWhere()).toEqual(exp)
    )

    it('should return a complex where clause with operators and or conections', () ->
        sql = new SqlExpression()
        sql.where({ age: { ">": 18, "<": 25 }, name: 'deividy' })
                .or({ test: { "between": [18,25] }, testing: 1234 })
                .and({ login: 'root'})

        exp = "where (age > 18 AND age < 25 AND name = 'deividy') "
        exp += "OR (test BETWEEN 18 AND 25 AND testing = 1234) "
        exp += "AND (login = 'root')"

        expect(sql.getWhere()).toEqual(exp)
    )

    it('should return a where clause with or using arrays', () ->
        sql = new SqlExpression()

        sql.where([{ age: 22, name: 'deividy' }, { age: 18, login: 'deividy' }])
        exp = "where ((age = 22 AND name = 'deividy') OR (age = 18 AND login = 'deividy'))"

        expect(sql.getWhere()).toEqual(exp)
    )

    it('should return a complex where clause', () ->
        sql = new SqlExpression()

        sql.where([{ age: 22, name: 'deividy' }, { age: 18, login: 'deividy' }])
            .and([{ login: 'test', pass: 12 }, { login: 'test123', pass: 123 } ])

        exp = "where ((age = 22 AND name = 'deividy') OR (age = 18 AND login = 'deividy')) "
        exp += "AND ((login = 'test' AND pass = 12) OR (login = 'test123' AND pass = 123))"
        expect(sql.getWhere()).toEqual(exp)
    )
)