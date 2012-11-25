_ = require('underscore')
engines = require('./engines.json')

class Database
    constructor: (@config) ->
        @adapter = @_getAdapter()

        dialect = @_getDialect()
        { @schema, @utils, @formatter } = dialect

    _getAdapter: () ->
        name = @config.adapter ? engines[@config.engine].adapter
        path = "./adapters/#{name}"
        adapter = require(path)
        return new adapter(@config)

    _getDialect: () ->
        name = @config.dialect ? engines[@config.engine].dialect
        path = "./dialects/#{name}"
        dialect = require(path)
        return new dialect(@)

    run: (stmt, callback) ->
        @execute(stmt, { onDone: () -> callback(null) }, callback)

    scalar: (query, callback) ->
        opt = {
            onAllRows: (rows) ->
                if (rows.length != 1)
                    e = "Expect query #{query} to return 1 row, " +
                        "but it returned #{rows.length} rows."
                    callback(e)

                callback(null, rows[0][0])
        }
        @execute(query, opt, callback)

    execute: (query, opt, callback) ->
        opt.onError = (e) -> callback(e)
        opt.stmt = query
        @adapter.execute(opt)

    array: (query, callback) ->
        a = []
        opt = {
           onRow: (row) -> a.push(row[0])
           onDone: () -> callback(null, a)
        }
        @execute(query, opt, callback)

    allRows: (query, callback) ->
        opt = { onAllRows: (rows) -> callback(null, rows) }
        @execute(query, opt, callback)

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
