should = require('should')
h = require('../test-helper')


utils = null

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
    before(() ->
        utils = h.getDb('mssql').utils
    )

    it('should create a date now', (done) ->
        utils.dbNow((err, date) ->
            x = new Date(date)
            date.toTimeString().should.eql(x.toTimeString())
            done()
        )
    )

    it('should create a date now on utc', (done) ->
        utils.dbUtcNow((err, date) ->
            x = new Date(date)
            date.toTimeString().should.eql(x.toTimeString())
            done()
        )
    )

    it('should check the offset to utc', (done) ->
        utils.dbUtcOffset((err, offset) ->
            offset.should.a('number')
            done()
        )
    )

)

describe('utils functions', () ->
    it('reads table names', (done) ->
        utils.getTableNames((err, tables) ->
            checkTables(tables)
            done()
        )
    )

    it('reads all columns in the database', (done) ->
        utils.getColumns((err, columns) ->
            checkColumns(columns)
            done()
        )
    )

    it('reads foreign keys', (done) ->
        utils.getForeignKeys((err, foreignKeys) ->
            checkForeignKeys(foreignKeys)
            done()
        )
    )

    it('reads key columns', (done) ->
        utils.getKeyColumns((err, keyColumns) ->
            checkKeyColumns(keyColumns)
            done()
        )
    )

    it('reads all metadata', (done) ->
        utils.getAllMetadata((err, m) ->
            checkTables(m.tables)
            checkColumns(m.columns)
            checkForeignKeys(m.foreignKeys)
            checkKeyColumns(m.keyColumns)
            done()
        )
    )
)
