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

    column: (c) ->
        expr = c.expr
        alias = c.alias

        if (expr instanceof SqlSelect)
            s = "(#{@select(expr)})"
        
        s = expr.toSql(@)

        s += " as #{@delimit(alias)}" if (alias?)
        return s

    columns: (columnList) ->
        return "*" if (columnList.length == 0)
        cols = (c.toSql(@) for c in columnList)
        return cols.join(", ")

    tables: (tableList) ->
        tables = (t.toSql(@) for t in tableList)
        return tables.join(", ")

    joins: (joinList) ->
        return '' unless joinList.length > 0
        joins = (j.toSql(@) for j in joinList)
        return joins.join(" ")

    from: (f) -> @column(f)
    join: (j) ->
        str = " INNER JOIN " + @column(j) + " ON " + j.predicate.toSql(@)

    select: (c) ->
        ret = "SELECT #{@columns(c.columns)} FROM #{@tables(c.tables)}"

        ret += @joins(c.joins)
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
