_ = require('underscore')
SqlExpression = require('./dialects/base-expression')
SqlFormatter = require('./dialects/base-formatter')

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

    kvFromObject: (obj) ->
        if (!_.isObject(obj))
            throw new Error("SqlStatement.ObjToKeysValues() supports only objects")

        ret = { keys: [], values: [], keysEquals: [] }
        for k, v of obj
            ret.keys.push(k)
            ret.values.push(format(v))
            ret.keysEquals.push("#{k} = #{format(v)}")

        return ret

    insert: (d) ->
        if (!_.isObject(d)) then throw new Error("SqlStatement.insert() supports only object")

        kv = @kvFromObject(d)

        return "INSERT INTO #{@table} (#{kv.keys.join(', ')}) VALUES (#{kv.values.join(', ')})"

    update: (d, w) ->
        if (!_.isObject(d)) then throw new Error("SqlStatement.update() supports only object")

        kv = @kvFromObject(d)

        @where(w)
        return "UPDATE #{@table} set #{kv.keysEquals.join(', ')} #{@sql.getWhere()}"

    delete: (w) ->
        @where(w)
        where = @sql.getWhere()
        if (!where)
            throw new Error("SqlStatement.delete() without where!")
        else
            return "DELETE FROM #{@table} #{where}"

    column: (c) ->
        if (c)
            if (_.isArray(c))
                @columns = @columns.concat(c)
            else @columns.push(c)

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