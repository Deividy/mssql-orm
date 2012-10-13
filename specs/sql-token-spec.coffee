{ SqlToken, SqlExpression, SqlName, SqlMultiPartName } = sql = require('../src/db/dialects/sql-grammar')

describe('SqlToken', () ->
    it('Can tell expressions from names', ->
        sql.nameOrExpr("Qty * Price").should.be.an.instanceOf(SqlExpression)
        sql.nameOrExpr("Foobar").should.be.an.instanceOf(SqlName)
    )

    it('Handles simple and multi-part names', ->
        sql.name('Some.Table').should.be.an.instanceOf(SqlName)
        sql.name(["SomeDb", "SomeSchema", "SomeTable"]).should.be.an.instanceOf(SqlMultiPartName)
    )
)
