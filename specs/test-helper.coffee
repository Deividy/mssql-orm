util = require('util')
sql = require('../src/sql')
path = require('path')

testConfig = require('./config.json')
sourceFolder = path.resolve(__dirname, '../src')
requireSrc = (pathToFile) -> require(path.resolve(sourceFolder, pathToFile))

SqlFormatter = requireSrc('dialects/sql-formatter')
ezekiel = requireSrc('ezekiel')
Database = requireSrc('db/database')

f = new SqlFormatter()
debug = false
db = null
defaultEngine = 'mssql'

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

    assert: (sql, expected, debug) ->
        ret = sql.toSql(f)
        if debug
            console.log("--- Return ---")
            console.log("'#{ret}'")
            console.log("---")
            console.log("--- Expected ---")
            console.log(expected)
            console.log("---")

        ret.should.eql(expected)

    inspect: (o) ->
        console.log(util.inspect(o, true, 5, true))

    getDb: (engine = defaultEngine) -> db
    newDb: newDb
    blankDb: () -> new Database({ database: 'blank' })
}
