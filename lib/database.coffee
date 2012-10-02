tds = require('tds')

class Database
    constructor: (@config) ->

    _connect = (callback) ->
        self = @
        @conn = new tds.Connection(@config)
        @conn.connect((err) ->
            if (err) 
                console.error('Received error: ', err)
            else
                self.conn.on('error', (error) ->
                  console.error('Received error', error)
                )
                self.conn.on('message', (message) ->
                  console.info('Received info', message)
                )
                callback(self.conn)
        )
    query: (stmt, callback) ->
        
    getRows: (stmt, callback) ->
        data = []
        _connect((conn) ->
            stmt = conn.createStatement(stmt)
            stmt.on('row', (row) ->
                data.push(row)
            )
            stmt.on('done', (done) ->
                callback(data)
            )
            stmt.execute()
        )

    _toJSON = (data) ->
        out = []
        for item in data
            if item.name == 'ROW'
                out.push(@_getColumns(item))
        return out

    _getColumns = (item) ->
        out = {}
        for col of item.metadata.columnsByName
            out[col] = item.getValue(col)
        return out

module.exports = Database
