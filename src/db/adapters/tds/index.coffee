tds = require('tds')
_ = require('underscore')

class TdsEngine
    constructor: (@config) ->

    connect: (options, callback) ->
        if arguments.length == 1
            callback = options
            options = {}
        config = _.clone(@config)
        if options?.master
            config.database = 'master'
        self = @
        @conn = new tds.Connection(config)
        @conn.connect((err) ->
            if (err)
                console.error('Received error: ', err)
                return
            else
                self.conn.on('error', options?.onConnectionError || self._onConnectionErrorDefault())
                self.conn.on('message', options?.onConnectionMessage || self._onConnectionMessageDefault())
                return callback(self.conn)
        )

    execute: (options) ->
        self = @
        sql = _.isString(options) && options || options?.stmt
        @connect(options, (conn) ->
            stmt = conn.createStatement(sql)
            stmt.on('row', options?.onRow || self._onRowDefault())
            stmt.on('done', options?.onDone || self._onDoneDefault())
            stmt.on('error', options?.onError || self._onErrorDefault())
            stmt.execute()
            return
        )

    # Default connection error handler
    _onConnectionErrorDefault: () ->
        return (err) ->
            throw new Error(err)

    # Defalt connection message handler
    _onConnectionMessageDefault: () ->
        return (message) ->
            console.info('Received info', message)

    # Default error handler
    _onErrorDefault: () ->
        return (err) ->
            throw new Error(err)

    # Defalt message handler
    _onMessageDefault: () ->
        return (message) ->
            console.info('Received info', message)

    # Defalt row handler
    _onRowDefault: () ->
        return (row) ->
            # console.info('Row info', row)

    # Defalt done handler
    _onDoneDefault: () ->
        return (done) ->
            # console.info('Done info', done)

    doesDatabaseExist: (name, callback) ->
        @execute(
            {
                master:true
                stmt:"SELECT DB_ID('#{name}');"
                onRow: (row) ->
                    return callback(row.getValue(0))
            }
        )

    createDatabase: (name, callback) ->
        @execute(
            {
                master:true
                stmt:"IF (DB_ID('#{name}') IS NULL) CREATE DATABASE #{name};"
                onDone: (done) ->
                    callback(done)
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
                onRow: (row) ->
                    return self._killProcess(row.getValue(0), callback) if row
                onDone: (done) ->
                    return callback(done)
            }
        )

    _killProcess: (id, callback) ->
        engine.execute(
            {
                master:true
                stmt:"KILL #{id}"
                onDone: (done) ->
                    return callback(done)
            }
        )

module.exports = TdsEngine