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

    conditionalObject: (obj) ->
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

    conditionalArray: (arr) ->
        clauses = []
        for a in arr
            clauses.push(@expression(a))

        return "(#{clauses.join(' OR ')})"

    where: (expr) ->
        return "" if (!expr)
        return "WHERE #{@conditional(expr)}"

    conditional: (t) ->
        return t.toSql(@) if (t instanceof SqlConditional)

        return "(#{t})" if (_.isString(t))
        return @conditionalArray(t) if (_.isArray(t))
        return @conditionalObject(t) if (_.isObject(t))

        throw new Error("Unsupported conditional " + t.toString())


    and: (a, b) ->
        return "(#{@conditional(a)}) AND (#{@conditional(b)})"

    or: (a, b) ->
        return "(#{@conditional(a)}) OR (#{@conditional(b)})"

module.exports = SqlFormatter
