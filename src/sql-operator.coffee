
_ = require('underscore')

format = SqlFormatter.f

class SqlOperator
    constructor: () ->
        @whereClause = ""

    sqlFromOperator: (key, op) ->
        clauses = []
        for k, v of op
            if (k == 'between')
                if (_.isArray(v) and v.length==2)
                    clauses.push("#{key} BETWEEN #{format(v[0])} AND #{format(v[1])}")
                else
                    throw new Error("Invalid between clause")
            else if (!_.isArray(v) && !_.isObject(v))
                clauses.push("#{key} #{k} #{format(v)}")
            else
                throw new Error("Not suported arrays or objects inside an object")

        return clauses.join(" AND ")

    sqlFromObject: (obj) ->
        clauses = []
        for key, value of obj

            if(_.isArray(value))
                values = _.reduce(value, (memo, val) ->
                    return "#{memo}, #{format(val)}"
                )
                clauses.push("#{key} IN (#{values})")
            else if (_.isObject(value))
                clauses.push(@sqlFromOperator(key, value))
            else
                clauses.push("#{key} = #{format(value)}")

        newClause = "(#{clauses.join(' AND ')})"

        return newClause

    sqlFromArray: (arr) ->
        clauses = []
        for a in arr
            if (_.isObject(a))
                clauses.push(@sqlFromObject(a))
            else
                throw new Error("Invalid clause, a where array can contains only objects")
        return "(#{clauses.join(' OR ')})"

    addClause: (w, conector) ->
        if (_.isArray(w))
            newClause = @sqlFromArray(w)
        else if (_.isObject(w))
            newClause = @sqlFromObject(w)
        else
            newClause = w

        if (!@whereClause)
            @whereClause = newClause
            return

        @whereClause = "(#{@whereClause} #{conector} #{newClause})"


    where: (w) ->
        if (@whereClause)
            throw new Error("Already use the .where, check your code")

        @addClause(w)
        return @

    and: (w) ->
        @addClause(w, "AND")
        return @

    or: (w) ->
        @addClause(w, "OR")
        return @

    getWhere: () ->
        if (@whereClause != "")
            return "where #{@whereClause}"
        else
            return ''

module.exports = SqlExpression
