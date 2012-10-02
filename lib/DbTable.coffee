SqlStatement = require('./SqlStatement')

class DbTable
    @defaultHandler = {
        success: (ret) ->
            console.log(ret)
        error: (err) ->
            console.error(err)
    }

    constructor: (@data) ->
        if(!@data) then @data = { }

    @insertOne: (data, callback) ->
        sql = new SqlStatement(@tableSchema)
        stmt = sql.insert(data)

        if(!callback)
            callback = @defaultHandler
        else 
            if (!callback.success)
                callback.success = @defaultHandler.success
            if (!callback.error)
                callback.error = @defaultHandler.error

        callback.success(stmt)
        
        
    @updateOne: (data, where, callback) ->

    @deleteOne: (where, callback) ->

    @findOne: (where, callback) ->

    @findMany: (where, callback) ->

    @deleteMany: (where, callback) ->

    @updateMany: (data, where, callback) ->

    save: ->
        #console.log(@tableSchema)

module.exports = DbTable

