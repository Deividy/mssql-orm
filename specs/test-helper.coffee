util = require('util')
sql = require('../src/sql')
path = require('path')

testConfig = require('./config.json')
sourceFolder = path.resolve(__dirname, '../src')
requireSrc = (pathToFile) -> require(path.resolve(sourceFolder, pathToFile))

SqlFormatter = requireSrc('sql-formatter')
Database = requireSrc('database')

f = new SqlFormatter()
debug = false
db = null
defaultEngine = 'mssql'

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


    getDb: (engine = defaultEngine) ->
        return db ?= new Database(testConfig.databases[engine])
}
