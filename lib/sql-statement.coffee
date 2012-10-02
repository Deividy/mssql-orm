_ = require('underscore')
SqlExpression = require('./sql-expression')


class SqlStatement extends SqlExpression
    constructor: (@tableSchema) ->
        @whereClause = []
        @columns = []

    save: () ->

    validate: (data) ->
        return true

    select: (w) ->
        where = @getWhere(w)
        columns = @getColumns()

        return "SELECT #{columns} FROM  #{@tableSchema.name} #{where}"

    insert: (data) ->
        if (!@validate(data))
            throw new Error("Invalid data! \n #{data}")

        keys = ""
        values = ""
        count = 1
        for key, val of data
            if (count > 1)
                keys += ", "
                values += ", "

            keys += key
            values += "'#{val}'"
            count++

        ret = "INSERT INTO #{@tableSchema.name} (#{keys}) VALUES (#{values})"

        return ret 

    update: (data, w) ->

    column: (c) ->
        if (_.isArray(c))
            for cl in c
                @columns.push(cl)
        else
            @columns.push(c)

    where: (w) ->
        @whereClause.push(w)

    getColumns: () ->
        columns = ''
        if (@columns.length >= 1)
            count = 1
            for c in @columns
                if (count > 1) then columns += ", "
                columns += c
                count++
        else
            columns = "*"

        return columns

    getWhere: (w) ->
        if (w) 
            v = @buildClauses(w)
        else
            v = @buildClauses(@whereClause)

        if (v)
            return "where #{v}"
        else
            return ""

module.exports = SqlStatement
