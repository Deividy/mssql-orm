util = require('util')

sql = require('../src/sql')
SqlFormatter = require('../src/base-formatter')

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
        console.log(util.inspect(o, true, 5, true))
}
