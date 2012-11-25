h = require('../test-helper')
Database = h.requireSrc('database')
TsqlSchema = h.requireSrc('dialects/tsql/tsql-schema')

db = h.getDb('mssql')

schema = null

describe('TsqlSchema', () ->
    before(() ->
        schema = new TsqlSchema(db)
    )

    it('reads table names', (done) ->
        schema.getTableNames((tables) ->
            tables.should.eql(['Customers', 'OrderLines', 'Orders', 'Products'])
            done()
        )
    )
)
