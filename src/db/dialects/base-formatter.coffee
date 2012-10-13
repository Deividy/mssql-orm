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

    doList: (collection, separator = ', ', prelude = '') ->
        return '' unless collection?.length > 0
        results = (i.toSql(@) for i in collection)
        return prelude + results.join(separator)

    columns: (columnList) ->
        return "*" if (columnList.length == 0)
        return @doList(columnList)

    tables: (tableList) -> @doList(tableList)

    joins: (joinList) -> @doList(joinList, ' ')

    from: (f) -> @column(f)
    join: (j) ->
        str = " INNER JOIN " + @column(j) + " ON " + j.predicate.toSql(@)

    select: (c) ->
        ret = "SELECT #{@columns(c.columns)} FROM #{@tables(c.tables)}"

        ret += @joins(c.joins)
        ret += @where(c)
        ret += @groupBy(c)
        ret += @orderBy(c)
        return ret

    where: (c) ->
        return " WHERE #{(c.whereClause.toSql(@))}" if (c.whereClause?)
        return ""

    groupBy: (c) -> @doList(c.groupings, ', ', ' GROUP BY ')

    orderBy: (c) -> @doList(c.orderings, ', ', ' ORDER BY ')
    ordering: (o) -> "#{o.expr.toSql(@)} #{o.direction}"

    insert: (i) ->
        return "INSERT #{@f(i.targetTable)}"

    update: (u) ->
        ret = "UPDATE #{@f(u.targetTable)} SET "
        ret += @doList(u.exprs)
        ret += @where(u)
        return ret

    updateExpr: (e) -> "#{@f(e.column)} = #{@f(e.value)}"

    delete: (d) ->
        ret = "DELETE FROM #{@f(d.targetTable)}"
        ret += @where(d)
        return ret

p = SqlFormatter.prototype
p.format = p.f

module.exports = SqlFormatter
