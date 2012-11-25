_ = require('underscore')
engines = require('./engines.json')

class Database
    constructor: (@config) ->
        @adapter = @_getAdapter()

        dialect = @_getDialect()
        { @utils, @formatter } = dialect

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
            rowShape: 'array'
            onAllRows: (rows) ->
                if (rows.length != 1)
                    e = "Expect query #{query} to return 1 row, " +
                        "but it returned #{rows.length} rows."
                    callback(e)

                callback(null, rows[0][0])
        }
        @execute(query, opt, callback)

    execute: (query, opt, callback) ->
        if _.isString(query)
            opt.stmt = query
        else
            _.defaults(opt, query)

        opt.onError = (e) -> callback(e)
        @adapter.execute(opt)

    array: (query, callback) ->
        a = []
        opt = {
            rowShape: 'array'
            onRow: (row) -> a.push(row[0])
            onDone: () -> callback(null, a)
        }
        @execute(query, opt, callback)

    allRows: (query, callback) ->
        opt = { onAllRows: (rows) -> callback(null, rows) }
        @execute(query, opt, callback)

module.exports = Database
