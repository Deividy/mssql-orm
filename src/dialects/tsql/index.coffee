Schema = require('./tsql-schema')
Formatter = require('./tsql-formatter')
Utils = require('./tsql-utils')

class Tsql
    constructor: (db) ->
        @schema = new Schema(db)
        @formatter = new Formatter(db)
        @utils = new Utils(db)

module.exports = Tsql
