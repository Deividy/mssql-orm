tds = require('tds')
_ = require('underscore')

class DatabaseEngine
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

module.exports = DatabaseEngine