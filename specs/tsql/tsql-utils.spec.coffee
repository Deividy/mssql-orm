should = require('should')

h = require('../test-helper')
Database = h.requireSrc('database')

db = h.getDb('mssql')
db_utils = db.utils

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

describe('TsqlUtils', () ->
    it('should create a date now', (done) ->
        db_utils.dbNow((err, date) ->
            x = new Date(date)
            date.toTimeString().should.eql(x.toTimeString())
            done()
        )
    )

    it('should create a date now on utc', (done) ->
        db_utils.dbUtcNow((err, date) ->
            x = new Date(date)
            date.toTimeString().should.eql(x.toTimeString())
            done()
        )
    )

    it('should check the offset to utc', (done) ->
        db_utils.dbUtcOffset((err, offset) ->
            offset.should.a('number')
            done()
        )
    )

)

schema = db.utils

describe('Schema functions', () ->
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
