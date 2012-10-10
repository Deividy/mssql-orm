sys = require('sys')

sql = require('../src/db/dialects/sql-grammar')
SqlFormatter = require('../src/db/dialects/base-formatter')

f = new SqlFormatter()
debug = false

module.exports = {
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
        console.log(sys.inspect(o, true, 5))
}
