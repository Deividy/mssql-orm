tds = require('tds')
_ = require('underscore')

class TdsAdapter
    constructor: (config) ->
        @config = _.clone(config)
        @config.database ?= 'master'

    connect: (options, callback) ->
        @conn = new tds.Connection(@config)
        @conn.connect((err) =>
            if (err)
                callback(err)
            else
                @conn.on('error', options.onError ? _.bind(@onConnectionError, @))
                @conn.on('message', options.onMessage ? _.bind(@onConnectionMessage, @))
                return callback(null, @conn)
        )

    execute: (options) ->
        self = @
        sql = _.isString(options) && options || options?.stmt
        fnErr = options.onError ? _.bind(@onExecuteError, @)

        @connect(options, (err, conn) ->
            if(err)
                fnErr(err)
                return

            stmt = conn.createStatement(sql)

            doRow = options.onRow?
            doAllRows = options.onAllRows?
            rows = [] if doAllRows

            if (doRow || doAllRows)
                stmt.on('row', (row) ->
                    out = {}
                    for col in row.metadata.columns
                        out[col.name] = out[col.index] = row.getValue(col.index)

                    if doRow
                        options.onRow(out, options)

                    if doAllRows
                        rows.push(out)

                    return
                )

            stmt.on('done', (affected) ->
                if doAllRows
                    options.onAllRows(rows, options)

                if options.onDone?
                    options.onDone(affected)
            )
                
            stmt.on('error', fnErr)
            stmt.execute()
            return
        )


    onConnectionMessage: (msg) ->

    onConnectionError: (err) ->
        throw new Error(err)

    onExecuteError: (err) ->
        throw new Error(err)

    doesDatabaseExist: (name, callback) ->
        @execute(
            {
                master: true
                stmt:"SELECT DB_ID('#{name}');"
                onRow: (row) -> callback(row[0]?)
            }
        )

    createDatabase: (name, callback) ->
        @execute(
            {
                master:true
                stmt:"IF (DB_ID('#{name}') IS NULL) CREATE DATABASE #{name};"
                onDone: (done) -> callback(done)
            }
        )

    dropDatabase: (name, callback) ->
        self = @
        @_killDatabaseProcesses(name, (done) ->
            self.execute(
                {
                    master:true
                    stmt:"IF (DB_ID('#{name}') IS NOT NULL) DROP DATABASE #{name};"
                    onDone: (dn) ->
                        return callback(dn)
                }
            )
        )

    _killDatabaseProcesses: (name, callback) ->
        self = @
        @execute(
            {
                master:true
                stmt:"SELECT SPId FROM MASTER..SysProcesses WHERE DBId =
                DB_ID('#{name}') AND cmd <> 'CHECKPOINT';"
                onRow: (row) -> self._killProcess(row[0], callback) if row
                onDone: (done) -> callback(done)
            }
        )

    _killProcess: (id, callback) ->
        engine.execute(
            {
                master:true
                stmt:"KILL #{id}"
                onDone: (done) -> callback(done)
            }
        )

module.exports = TdsAdapter
