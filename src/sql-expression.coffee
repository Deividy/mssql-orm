_ = require('underscore')

class SqlExpression
    constructor: () ->
        @whereClause = ""

    sqlFromOperator: (key, op) ->
        clauses = []
        for k, v of op
            if (k == 'between')
                if (_.isArray(v) and v.length==2)
                    if (_.isString(v[0])) then value = "'#{v[0]}'"
                    if (_.isString(v[1])) then value = "'#{v[1]}'"

                    clauses.push("#{key} BETWEEN #{v[0]} AND #{v[1]}")

                else
                    throw new Error("Invalid between clause")

            else if (!_.isArray(v) && !_.isObject(v))
                if (_.isString(v)) then value = "'#{v}'"
                clauses.push("#{key} #{k} #{v}")

            else
                throw new Error("Not suported arrays or objects inside an object")

        return clauses.join(" AND ")

    sqlFromObject: (obj) ->
        clauses = []
        for key, value of obj

            if(_.isArray(value))
                values = _.reduce(value, (memo, val) ->
                    if (_.isString(val)) then val = "'#{val}'"

                    return "#{memo}, #{val}"
                )
                clauses.push("#{key} IN (#{values})")

            else if (_.isObject(value))
                clauses.push(@sqlFromOperator(key, value))
            else
                if (_.isString(value)) then value = "'#{value}'"
                clauses.push("#{key} = #{value}")

        newClause = clauses.join(' AND ')

        return newClause

    sqlFromArray: (arr) ->
        clauses = []
        for a in arr
            if (_.isObject(a))
                clauses.push("(#{@sqlFromObject(a)})")
            else
                throw new Error("Invalid clause, a where array can contains only objects")
        return "(#{clauses.join(' OR ')})"

    whereHandler: (w, conector) ->
        if (_.isArray(w))
            newClause = @sqlFromArray(w)
        else if (_.isObject(w))
            newClause = @sqlFromObject(w)
        else
            newClause = w

        if (@whereClause != "")
            if (@whereClause[0] != '(' && @whereClause[(@whereClause.length-1)] != ')')
                @whereClause = "(#{@whereClause})"

            if (newClause[0] != '(' && newClause[(newClause.length-1)] != ')')
                newClause = "(#{newClause})"

            @whereClause = "#{@whereClause} #{conector} #{newClause}"
        else
            @whereClause = "#{newClause}"

    where: (w) ->
        if (@whereClause)
            throw new Error("Already use the .where, check your code")

        @whereHandler(w)
        return @

    and: (w) ->
        @whereHandler(w, "AND")
        return @

    or: (w) ->
        @whereHandler(w, "OR")
        return @

    getWhere: () ->
        if (@whereClause != "")
            return "where #{@whereClause}"
        else
            return ''

module.exports = SqlExpression