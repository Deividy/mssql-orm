{ SqlToken, SqlExpression } = sql = require('../src/db/dialects/sql-grammar')

describe('SqlToken', () ->
    it('Can tell expressions from names', ->
        a = SqlToken.nameOrExpr("Qty * Price")
    )
)
