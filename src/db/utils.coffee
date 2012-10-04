DatabaseEngine = require('./adapters/tds')

class DatabaseUtils
    constructor: (@config) ->
        @engine = new DatabaseEngine(@config)

    dbNow: (callback) ->
    	@engine.execute(
            {
                master:true
                stmt:"SELECT GETDATE();"
                onRow: (row) ->
                    callback(row.getValue(0))
            }
        )

    dbUtcNow: (callback) ->
    	@engine.execute(
            {
                master:true
                stmt:"SELECT GETUTCDATE();"
                onRow: (row) ->
                    callback(row.getValue(0))
            }
        )

    dbUtcOffset: (callback) ->
    	@engine.execute(
            {
                master:true
                stmt:"SELECT DATEDIFF(mi, GETUTCDATE(), GETDATE());"
                onRow: (row) ->
                    callback(row.getValue(0))
            }
        )

module.exports = DatabaseUtils