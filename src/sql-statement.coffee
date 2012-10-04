_ = require('underscore')
SqlExpression = require('./sql-expression')
SqlFormatter = require('./sql-formatter')

format = SqlFormatter.f

class SqlStatement
    constructor: (@table) ->
        @columns = []
        # Need to initialize an instance of SqlExpression to all. Otherwise, will be a mess.
        @sql = new SqlExpression()

    # SqlExpression methods
    where: (w) ->
        @sql.where(w)
        return @

    and: (w) ->
        @sql.and(w)
        return @

    or: (w) ->
        @sql.or(w)
        return @

    # Statement methods
    select: (c, w) ->
        @column(c)
        @where(w)

        return "SELECT #{@getColumns()} FROM #{@table} #{@sql.getWhere()}"

    objToKeysValues: (obj) ->
        if (!_.isObject(obj))
            throw new Error("ObjToKeysValues supports only objects")

        ret = { keys: [], values: [], keysEquals: [] }
        for k, v of obj
            ret.keys.push(k)
            ret.values.push(format(v))
            ret.keysEquals.push("#{k} = #{format(v)}")

        return ret

    insertArray: (a) ->
        ret = []
        if (_.isArray(a))
            for d in a
                ret.push(@insert(d))
        else
            throw new Error("arrayToSqls expects an array")

        return ret.join("; ")

    insert: (d) ->
        if (_.isArray(d)) then return @insertArray(d)
        kv = @objToKeysValues(d)

        return "INSERT INTO #{@table} (#{kv.keys.join(', ')}) VALUES (#{kv.values.join(', ')})"

    update: (d, w) ->
        if (_.isArray(d))
            throw new Error("Update using array is not supported")

        kv = @objToKeysValues(d)

        @where(w)
        return "UPDATE #{@table} set #{kv.keysEquals.join(', ')} #{@sql.getWhere()}"

    delete: (w) ->
        @where(w)
        where = @sql.getWhere()
        if (!where)
            throw new Error("delete withou where!")
        else
            return "DELETE FROM #{@table} #{where}"

    column: (c) ->
        if (c)
            if (_.isArray(c))
                @columns = @columns.concat(c)
            else
                @columns.push(c)

        return @

    getColumns: () ->
        if (@columns.length >= 1)
            columns = _.reduce(@columns, (memo, val) ->
                cols = []
                if (_.isObject(memo))
                    for k, v of memo
                        cols.push("#{k} as #{v}")

                else cols.push(memo)

                if (_.isObject(val))
                    for k, v of val
                        cols.push("#{k} as #{v}")

                else cols.push(val)

                return cols.join(", ")
            )
        else
            columns = "*"

        return columns

module.exports = SqlStatement