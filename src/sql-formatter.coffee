_ = require('underscore')
SqlToken = require('./sql-where').SqlToken

class SqlFormatter

    @f: (v) ->
        if (_.isString(v))
            return "'" + v.replace("'","''") + "'"

        return v.toString()

    format = SqlFormatter.f

    operator: (key, op) ->
        clauses = []
        for k, v of op
            if (k == 'between')
                if (_.isArray(v) && v.length == 2)
                    clauses.push("#{key} BETWEEN #{format(v[0])} AND #{format(v[1])}")
                else
                    throw new Error("Invalid between clause")

            else if (!_.isArray(v) && !_.isObject(v))
                clauses.push("#{key} #{k} #{format(v)}")

            else
                #throw new Error("Not suported arrays or objects inside an object")

        return clauses.join(" AND ")

    object: (obj) ->
        clauses = []
        for key, value of obj

            if(_.isArray(value))
                values = _.reduce(value, (memo, val) ->
                    return "#{memo}, #{format(val)}"
                )
                clauses.push("#{key} IN (#{values})")

            else if (_.isObject(value))
                clauses.push(@operator(key, value))
            else
                clauses.push("#{key} = #{format(value)}")

        newClause = "(#{clauses.join(' AND ')})"

        return newClause

    array: (arr) ->
        clauses = []
        for a in arr
            clauses.push(@expression(a))

        return "(#{clauses.join(' OR ')})"

    where: (expr) ->
        return "" if (!expr)
        return "WHERE #{@expression(expr)}"

    expression: (t) ->
        return t.toSql(@) if (t instanceof SqlToken)

        return "(#{t})" if (_.isString(t))
        return @array(t) if (_.isArray(t))
        return @object(t) if (_.isObject(t))


    and: (a, b) ->
        return "(#{@expression(a)}) AND (#{@expression(b)})"

    or: (a, b) ->
        return "(#{@expression(a)}) OR (#{@expression(b)})"

module.exports = SqlFormatter