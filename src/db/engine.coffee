class DatabaseEngine
    engines: {
        mssql : {
            defaultAdapter: 'tds'
            dialect: 'tsql'
        }

        mysql: {
            defaultAdapter: 'mysql'
            dialect: 'mysql'
        }

        meuDb: {
            defaultAdapter: 'meuDb'
            dialect: 'myDialect'
        }
    }

    constructor: (@options) ->
        @engine = @options?.engine
        @adapter = @_getAdapter()
        @dialect = @_getDialect()

    _getAdapter: () ->
        name = @options?.adapter || 'defaultAdapter'
        path = "./adapters/#{@engines[@engine][name]}"
        adapter = require(path)
        return new adapter(@options)

    _getDialect: () ->
        path = "./dialects/#{@engines[@engine].dialect}"
        dialect = require(path)
        return new dialect(@options)

module.exports = DatabaseEngine