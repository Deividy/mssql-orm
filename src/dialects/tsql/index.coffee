Formatter = require('./tsql-formatter')
Utils = require('./tsql-utils')

class Tsql
    constructor: (db) ->
        @formatter = new Formatter(db)
        @utils = new Utils(db)

module.exports = Tsql
