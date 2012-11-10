Schema = require('./tsql-schema')
Formatter = require('./tsql-formatter')

class Tsql
    constructor: (db) ->
        @schema = new Schema(db)
        @formatter = new Formatter(db)

module.exports = Tsql
