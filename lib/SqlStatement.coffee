SqlExpression = require('./SqlExpression')
_ = require('underscore')

class SqlStatement
    constructor: (@tableSchema) ->
        @whereClause = []
        @columns = []

    save: () ->

    validate: (column, value) ->
        return true

    select: (w) ->
        where = @getWhere(w)
        columns = @getColumns()

        return "SELECT #{columns} FROM  #{@tableSchema.name} #{where}"

    insertOne: (data) ->
        keys = ""
        values = ""
        count = 1
        for key, val of data
            if (count > 1)
                keys += ", "
                values += ", "

            if (@validate(key, val))
                keys += key
                values += "'#{val}'"
                count++
            else
                console.error("INVALID COLUMN / VALUE", key, val)
                
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
        s = new SqlExpression()
        if (w) 
            v = s.build(w)
        else
            v = s.build(@whereClause)
        
        if (v)
            return "where #{v}"
        else
            return ""

module.exports = SqlStatement