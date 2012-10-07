_ = require('underscore')
{ SqlPredicate, SqlToken, SqlSelect } = require('./sql-grammar')

SqlIdentifier = SqlToken.SqlIdentifier

class SqlFormatter
    @f: (v) ->
        if (_.isString(v))
            return "'" + v.replace("'","''") + "'"

        return v.toString()

    literal: (l) -> SqlFormatter.f(l)

    format = SqlFormatter.f

    operator: (key, op) ->
        clauses = []
        for k, v of op
            if (k == 'between')
                if (_.isArray(v) && v.length == 2)
                    p = "#{key} BETWEEN #{format(v[0])} AND #{format(v[1])}"
                    clauses.push(p)
                else
                    throw new Error("Invalid between clause")

            else if (!_.isArray(v) && !_.isObject(v))
                clauses.push("#{key} #{k} #{format(v)}")

            else
                throw new Error("Not suported arrays or objects inside an object")

        return clauses.join(" AND ")

    predicateObject: (obj) ->
        clauses = []
        for key, value of obj
            # HACK: Need find another way to get tableAlias here
            key = "#{@delimit(@tableAlias)}.#{@delimit(key)}" if (@tableAlias)
            #
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

    predicateArray: (arr) ->
        clauses = []
        for a in arr
            clauses.push(@predicate(a))

        return "(#{clauses.join(' OR ')})"


    predicate: (t) ->
        return t.toSql(@) if (t instanceof SqlPredicate)
        return "(#{t})" if (_.isString(t))
        return @predicateArray(t) if (_.isArray(t))
        return @predicateObject(t) if (_.isObject(t))
        throw new Error("Unsupported predicate " + t.toString())


    and: (a, b) ->
        return "(#{@predicate(a)} AND #{@predicate(b)})"

    or: (a, b) ->
        return "(#{@predicate(a)} OR #{@predicate(b)})"

    identifier: (c) -> "#{delimit(c.tableName)}.#{delimit(c.columnName)}"

    identifierGuess: (c) ->
        return "#{@delimit(c.guessTable)}.#{@delimit(c.given)}" if (c.guessTable?)
        return @delimit(c.given)

    name: (n) ->

    delimit: (s) ->
        return "[#{s}]"

    formatAlias: (c) ->
        column = c[0]
        alias = c[1]

        if (column instanceof SqlSelect)
            s = "(#{@select(column)})"
        else
            s = column.toSql(@)

        s += " as #{@delimit(alias)}" if (alias?)
        return s

    columns: (columnList) ->
        return "*" if (columnList.length == 0)
        cols = (@formatAlias(c) for c in columnList)
        return cols.join(", ")

    tables: (tableList) ->
        tables = (@formatAlias(t) for t in tableList)
        return tables.join(", ")

    select: (c) ->
        ret = "SELECT #{@columns(c.columns)} FROM #{@tables(c.tables)} "

        ret += @getWhere(c)
        ret += @getHaving(c)
        return ret

    getHaving: (c) ->
        return "HAVING #{@predicate(c.havingClause)}" if (c.havingClause?)
        return ""

    getWhere: (c) ->
        # HACK: Need find another way to send tableAlias for predicateObject()
        @tableAlias = c.lastAlias if (c.lastAlias?)
        #       
        return "WHERE #{@predicate(c.whereClause)}" if (c.whereClause?)
        return ""

module.exports = SqlFormatter
