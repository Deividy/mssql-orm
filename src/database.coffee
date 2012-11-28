_ = require('underscore')

dbObjects = require('./db-objects')
{ DbObject, Table, Column, Key, ForeignKey } = dbObjects

class Database extends DbObject
    constructor: (@config) ->
        @tables = []
        @tablesByName = {}
        @tablesByAlias = {}
        @constraintsByName = {}
        @name = @config.database

        @adapter = @utils = @formatter = null

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
        @addSchemaItems(Table, schema.tables, @)
        @addSchemaItems(Column, schema.columns)
        @addSchemaItems(Key, schema.keys)
        @addSchemaItems(ForeignKey, schema.foreignKeys)

        @addKeyColumns(schema.keyColumns)

    addSchemaItems: (constructor, list, parent) ->
        for i in list
            p = parent ? @tablesByName[i.tableName]
            new constructor(p, i)

    addKeyColumns: (list) ->
        for i in list
            c = @constraintsByName[i.constraintName]
            c.addColumn(i)

module.exports = dbObjects.Database = Database
