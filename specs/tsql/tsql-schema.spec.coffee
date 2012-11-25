h = require('../test-helper')
should = require('should')
Database = h.requireSrc('database')
TsqlSchema = h.requireSrc('dialects/tsql/tsql-schema')

db = h.getDb('mssql')

schema = null

checkTables = (tables) -> tables.should.eql(['Customers', 'OrderLines', 'Orders', 'Products'])

checkColumns = (columns) ->
    columns.length.should.eql(12)
    for c in columns
        should.exist(c.name)
        should.exist(c.tableName)

checkForeignKeys = (foreignKeys) ->
    foreignKeys.length.should.eql(3)

checkKeyColumns = (keyColumns) ->
    keyColumns.length.should.eql(10)
    for c in keyColumns
        should.exist(c.constraintName)
        should.exist(c.tableName)
        should.exist(c.columnName)
        should.exist(c.position)

describe('TsqlSchema', () ->
    before(() ->
        schema = new TsqlSchema(db)
    )

    it('reads table names', (done) ->
        schema.getTableNames((err, tables) ->
            checkTables(tables)
            done()
        )
    )

    it('reads all columns in the database', (done) ->
        schema.getColumns((err, columns) ->
            checkColumns(columns)
            done()
        )
    )

    it('reads foreign keys', (done) ->
        schema.getForeignKeys((err, foreignKeys) ->
            checkForeignKeys(foreignKeys)
            done()
        )
    )

    it('reads key columns', (done) ->
        schema.getKeyColumns((err, keyColumns) ->
            checkKeyColumns(keyColumns)
            done()
        )
    )

    it('reads all metadata', (done) ->
        schema.getAllMetadata((err, m) ->
            checkTables(m.tables)
            checkColumns(m.columns)
            checkForeignKeys(m.foreignKeys)
            checkKeyColumns(m.keyColumns)
            done()
        )
    )
)
