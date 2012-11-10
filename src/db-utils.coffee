DatabaseEngine = require('./db-engine')

class DatabaseUtils
    constructor: (@config) ->
        @engine = new DatabaseEngine(@config)

    dbNow: (callback) ->
    	@engine.adapter.execute(
            {
                master:true
                stmt:"SELECT GETDATE();"
                onRow: (row) ->
                    callback(row.getValue(0))
            }
        )

    dbUtcNow: (callback) ->
    	@engine.adapter.execute(
            {
                master:true
                stmt:"SELECT GETUTCDATE();"
                onRow: (row) ->
                    callback(row.getValue(0))
            }
        )

    dbUtcOffset: (callback) ->
    	@engine.adapter.execute(
            {
                master:true
                stmt:"SELECT DATEDIFF(mi, GETUTCDATE(), GETDATE());"
                onRow: (row) ->
                    callback(row.getValue(0))
            }
        )

module.exports = DatabaseUtils
