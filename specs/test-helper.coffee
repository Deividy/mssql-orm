util = require('util')
sql = require('../src/sql')
path = require('path')

testConfig = require('./config.json')
sourceFolder = path.resolve(__dirname, '../src')
requireSrc = (pathToFile) -> require(path.resolve(sourceFolder, pathToFile))

SqlFormatter = requireSrc('sql-formatter')
ezekiel = requireSrc('ezekiel')

f = new SqlFormatter()
debug = false
db = null
defaultEngine = 'mssql'

before((done) ->
    ezekiel.connect(testConfig.databases['mssql'], (err, database) ->
        if (err)
            throw new Error(err)

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
}
