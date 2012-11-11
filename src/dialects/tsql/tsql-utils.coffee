DbUtils = require('../../db-utils')

class TsqlUtils extends DbUtils
    constructor: (@db) ->
        @stmts = {
            dbNow: 'SELECT GETDATE()'
            dbUtcNow: 'SELECT GETUTCDATE()'
            dbUtcOffset: "SELECT DATEDIFF(mi, GETUTCDATE(), GETDATE())"
        }

module.exports = TsqlUtils
