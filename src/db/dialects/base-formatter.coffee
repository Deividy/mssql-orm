_ = require('underscore')
{ SqlPredicate, SqlToken, SqlSelect, SqlExpression } = require('./sql-grammar')

SqlIdentifier = SqlToken.SqlIdentifier

rgxParseName = ///
    ( [^.]+ )   # anything that's not a .
    \.?         # optional . at the end
///g

class SqlFormatter
    f: (v) ->
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
            when 'IN' then "(#{@f(right)})"
            when 'BETWEEN' then "#{@f(right[0])} AND #{@f(right[1])}"
            else @f(right)

        return "#{@f(left)} #{op} #{r}"

    and: (terms) ->
        t = _.map(terms, @f, @)
        return "(#{t.join(" AND " )})"

    or: (terms) ->
        t = _.map(terms, @f, @)
        return "(#{t.join(" OR " )})"

    name: (n) ->
        parts = @parseName(n.name)
        if (parts.length == 1 && n.prefixHint?)
            parts.unshift(n.prefixHint)
        return @names(parts)

    multiPartName: (m) -> @names(m.parts)
    names: (names) -> _.map(names, (p) -> "[#{p}]").join(".")

    parseName: (name) ->
        parts = []
        while (match = rgxParseName.exec(name))
            parts.push(match[1])
        return parts

    delimit: (s) ->
        return "[#{s}]"

    formatAlias: (c) ->
        column = c[0]
        alias = c[1]

        if (column instanceof SqlSelect)
            s = "(#{@select(column)})"
        
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
        ret = "SELECT #{@columns(c.columns)} FROM #{@tables(c.tables)}"

        ret += @getWhere(c)
        ret += @getHaving(c)
        return ret

    getHaving: (c) ->
        return " HAVING #{@predicate(c.havingClause)}" if (c.havingClause?)
        return ""

    getWhere: (c) ->
        return " WHERE #{(c.whereClause.toSql(@))}" if (c.whereClause?)
        return ""

    insert: (i) ->
        return "INSERT #{@f(i.targetTable)}"

    update: (u) ->
        return "UPDATE #{@f(u.targetTable)}"

    delete: (d) ->
        return "DELETE FROM #{@f(d.targetTable)}"

p = SqlFormatter.prototype
p.format = p.f

module.exports = SqlFormatter
