_ = require('underscore')
{ SqlPredicate, SqlToken, SqlSelect, SqlExpression } = require('./sql-grammar')

SqlIdentifier = SqlToken.SqlIdentifier

class SqlFormatter
    format: (v) ->
        return v.toSql(@) if v instanceof SqlToken
        return @literal(v)

    literal: (l) ->
        if (_.isString(l))
            return "'" + l.replace("'","''") + "'"

        return l.toString()

    parens: (contents) -> "(#{contents.toSql(@)})"

    relop: (left, op, right) ->
        # MUST: replace with data driven approach
        op = op.toUpperCase()
        r = switch op
            when 'IN' then "(#{@format(right)})"
            when 'BETWEEN' then "#{@format(right[0])} AND #{@format(right[1])}"
            else @format(right)

        return "#{@format(left)} #{op} #{r}"

    and: (terms) ->
        t = _.map(terms, ((t) -> @format(t)), @)
        return "(#{t.join(" AND " )})"

    or: (terms) ->
        t = _.map(terms, ((t) -> @format(t)), @)
        return "(#{t.join(" OR " )})"

    name: (name) -> name.n

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
