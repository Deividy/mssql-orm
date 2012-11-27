_ = require('underscore')

engines = require('./engines.json')
dbObjects = require('./db-objects')

{ DbObject, Table, Column, Key, ForeignKey, Constraint } = dbObjects

class Database extends DbObject
    constructor: (@config) ->
        @tables = []
        @tablesByName = {}
        @tablesByAlias = {}
        @constraintsByName = {}
        @name = @config.database

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
                    e = "Expected query #{query} to return 1 row, " +
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

    loadSchema: (schema) ->
        for n in schema.tableNames
            table = new Table(@, n)
            @tables.push(table)
            @tablesByName[n] = table

        @addSchemaItems(Column, schema.columns)
        @addSchemaItems(Key, schema.keys)
        @addSchemaItems(ForeignKey, schema.foreignKeys)

        @addKeyColumns(schema.keyColumns)

    addSchemaItems: (constructor, list) ->
        for i in list
            t = @tablesByName[i.tableName]
            new constructor(t, i)

    addKeyColumns: (list) ->
        for i in list
            c = @constraintsByName[i.constraintName]
            c.addColumn(i)

# We don't want users to instantiate Database directly for a number of reasons, but the fundamental
# point is that we cannot guarantee a valid working instance without doing async work. Also, we may
# want to check things like db version before exposing certain functionality. Loading a schema is
# another thing some people want before they get their db instance.
#
# On the error front, we could have an instantaneous error (bad config) or an error when first
# trying to connect (requires async work). So new Database() is just not nice, it would make it
# a mess for the caller to correctly check for errors. We go for this little factory instead, and as
# a bonus we can implement methods that create a DB before connecting to it, stuff like that.

module.exports = {
    connect: (config, cb) ->
        # MUST: test that config is OK, test first connection, load schema when appropriate
        db = new Database(config)
        cb(null, db)
}
