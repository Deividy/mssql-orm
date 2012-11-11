DatabaseEngine = require('./db-engine')

class Database
    constructor: (@config) ->
        @engine = new DatabaseEngine(@config)
        @adapter = @engine.adapter

        # MUST: fix this
        dialect = require('./dialects/tsql')
        { @schema, @utils, @formatter } = new dialect(@)

    query: (stmt, callback) ->
        @adapter.execute({
            stmt: stmt
            onDone: (done) ->
                return callback(done)
        })

    scalar: (query, callback) ->
        @adapter.execute(
            stmt: query
            onRow: (row) ->
                callback(row.getValue(0))
        )

    getRows: (stmt, callback) ->
        self = @
        data = []
        @adapter.execute({
            stmt: stmt
            onRow: (row) ->
                data.push(self._getColumns(row))
                return
            onDone: (done) ->
                return callback(data)
        })

    _toJSON: (data) ->
        out = []
        for item in data
            if item.name == 'ROW'
                out.push(@_getColumns(item))
        return out

    _getColumns: (item) ->
        out = {}
        for col of item.metadata.columnsByName
            out[col] = item.getValue(col)
        return out

module.exports = Database
