_ = require('underscore')
{ SqlPredicate, SqlToken } = require('./sql-grammar')
SqlSelect = require('./sql-select')

SqlIdentifier = SqlToken.SqlIdentifier

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
        return "#{@delimit(c.guessTable)}.#{@delimit(c.given)}" if (c.guessTable)
        return @delimit(c.given)

    delimit: (s) -> "[#{s}]"

    column: (c) ->
        column = c[0]
        alias = c[1]

        if (column instanceof SqlSelect)
            s = "(#{@select(column)})"
        else
            s = column.toSql(@)

        s += " as #{@delimit(alias)}" if (alias)
        return s

    columns: (columnList) ->
        return "*" if (columnList.length == 0)
        cols = (@column(c) for c in columnList)
        return cols.join(", ")

    tables: (tableList) ->
        tables = (@column(t) for t in tableList)
        return tables.join(", ")

    select: (c) ->
        ret = "SELECT #{@columns(c.columns)} FROM #{@tables(c.tables)}"

        #ret += "#{c.lastAlias} " if (c.lastAlias != c.lastTable)
        ret += "WHERE #{@predicate(c.whereClause)}" if (c.whereClause)
        ret += "HAVING #{@predicate(c.havingClause)}" if (c.havingClause)

        return ret

module.exports = SqlFormatter
