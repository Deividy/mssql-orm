SqlStatement = require('./sql-statement')

class DbTable
    @database: null

    @defaultHandler = {
        success: (ret) ->
            console.log(ret)
        error: (err) ->
            console.error(err)
    }

    @setDatabase: (database) ->
        @database = database

    constructor: (@data) ->
        if(!@data) then @data = { }

    @insertOne: (data, callback) ->
        sql = new SqlStatement(@tableSchema.name)
        stmt = sql.insert(data)

        if(!callback)
            callback = @defaultHandler
        else
            if (!callback.success)
                callback.success = @defaultHandler.success
            if (!callback.error)
                callback.error = @defaultHandler.error
        return @database.query(stmt, callback.success) if @database
        return callback.success(stmt)

    @updateOne: (data, where, callback) ->

    @deleteOne: (where, callback) ->

    @findOne: (where, callback) ->

    # MUST: refactor, this is just a temp code
    @findMany: (where, callback) ->
        if arguments.length == 1
            callback = where
            where = null
        sql = new SqlStatement(@tableSchema.name)
        stmt = sql.select('*')
        if(!callback)
            callback = @defaultHandler
        else
            if (!callback.success)
                callback.success = @defaultHandler.success
            if (!callback.error)
                callback.error = @defaultHandler.error
        return @database.getRows(stmt, callback.success) if @database
        return callback.success(stmt)

    @deleteMany: (where, callback) ->

    @updateMany: (data, where, callback) ->

    save: ->
        #console.log(@tableSchema)

module.exports = DbTable

