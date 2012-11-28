util = require('util')
sql = require('../src/sql')
path = require('path')

testConfig = require('./config.json')
sourceFolder = path.resolve(__dirname, '../src')
requireSrc = (pathToFile) -> require(path.resolve(sourceFolder, pathToFile))

SqlFormatter = requireSrc('dialects/sql-formatter')
ezekiel = requireSrc('ezekiel')
Database = requireSrc('db/database')

debug = false
db = null
defaultEngine = 'mssql'

newSchema = () -> {
    tables: [
        { name: 'Customers', }
        { name: 'Orders' }
    ]
    columns: [
        { tableName: 'Customers', name: 'Id', position: 1 }
        { tableName: 'Customers', name: 'FirstName', position: 2 }
    ]
    keys: []
    foreignKeys: []
    keyColumns: []
}

newAliasedSchema = () -> {
    tables: [
        { name: 'tblCustomers', alias: 'Customers' }
        { name: 'tblOrders', alias: 'Orders' }
    ]
    columns: [
        { tableName: 'tblCustomers', name: 'zCustomerID', alias: 'id', position: 1 }
        { tableName: 'tblCustomers', name: 'zCustomerFirstName', alias: 'FirstName', position: 2 }
    ]
    keys: []
    foreignKeys: []
    keyColumns: []
}


blankDb = () -> new Database({ database: 'blank' })

aliasDb = () ->
    db = new Database({database: 'alias'})
    db.loadSchema(newAliasedSchema())
    return db

f = new SqlFormatter(blankDb())
aliasF = new SqlFormatter(aliasDb())

assertSqlFormatting = (formatter, sql, expected, debug) ->
    ret = sql.toSql(formatter)
    if (ret != expected) || debug
        console.log("--- Return ---")
        console.log("'#{ret}'")
        console.log("---")
        console.log("--- Expected ---")
        console.log(expected)
        console.log("---")

    ret.should.eql(expected)

newDb = (cb) ->
    ezekiel.connect(testConfig.databases['mssql'], (err, database) ->
        if (err)
            throw new Error('Could not connect to DB while testing: ' + err)

        cb(database)
    )

before((done) ->
    newDb((database) ->
        db = database
        done()
    )
)

module.exports = {
    testConfig: testConfig
    requireSrc: requireSrc
    defaultDbConfig: testConfig.databases[defaultEngine]

    assertSql: (sql, expected, debug) -> assertSqlFormatting(f, sql, expected, debug)
    assertAlias: (sql, expected, debug) -> assertSqlFormatting(aliasF, sql, expected, debug)

    inspect: (o) -> console.log(util.inspect(o, true, 5, true))

    getDb: (engine = defaultEngine) -> db
    newDb: newDb

    newSchema: newSchema
    newAliasedSchema: newAliasedSchema
    blankDb: blankDb
}
