h = require('../test-helper')
Database = h.requireSrc('database')
TsqlSchema = h.requireSrc('dialects/tsql/tsql-schema')

db = h.getDb('mssql')

schema = null

describe('TsqlSchema', () ->
   it('can be instantiated for the test database', () ->
       schema = new TsqlSchema(db)
       schema.should.be.an.instanceOf(TsqlSchema)
   )
)
