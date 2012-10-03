_ = require('underscore')
SqlExpression = require('./sql-expression')


class SqlStatement
    constructor: (@table) ->
        @columns = []
        @sql = new SqlExpression()

    # SqlExpression functions
    where: (w) ->
        @sql.where(w)
        return @
    and: (w) ->
        @sql.and(w)
        return @
    or: (w) ->
        @sql.or(w)
        return @

    save: () ->

    select: (w) ->
        select = "SELECT #{@getColumns()} FROM #{@table} #{@sql.getWhere()}"
        return select

    insert: (data) ->

    update: (data, w) ->

    column: (c) ->
        if (_.isArray(c))
            for cl in c
                @columns.push(cl)
        else
            @columns.push(c)


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

module.exports = SqlStatement