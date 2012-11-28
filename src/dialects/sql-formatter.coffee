_ = require('underscore')
{ SqlPredicate, SqlToken, SqlSelect, SqlExpression } = require('../sql')

SqlIdentifier = SqlToken.SqlIdentifier

rgxParseName = ///
    ( [^.]+ )   # anything that's not a .
    \.?         # optional . at the end
///g

rgxExpression = /[()\+\*\-/]/

class SqlFormatter
    constructor: (@db) ->

    f: (v) ->
        return v.toSql(@) if v instanceof SqlToken
        return @literal(v)

    literal: (l) ->
        if (_.isString(l))
            return "'" + l.replace("'","''") + "'"

        return l.toString()

    parens: (contents) -> "(#{contents.toSql(@)})"

    isExpression: (e) -> rgxExpression.test(e)

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

    aliasedExpression: (e) ->
        expr = e.expr
        alias = e.alias

        if (expr instanceof SqlToken)
            s = "(#{expr.toSql(@)})"
        else if (e._model?)
            # MUST: we assume the model is a DB object at this point. We'll need to handle
            # virtual columns, tables, etc.
            s = @delimit(e._model.name)
            alias = e.expr
        else if @isExpression(expr)
            s = "#{expr}"
        else if _.isString(expr)
            # MUST: use a different method here that parses a raw SQL name
            s = @delimit(expr)
            alias ?= expr
        else
            s = @literal(expr)

        s += " as #{@delimit(alias)}" if (alias?)
        return s


    column: (c) -> @aliasedExpression(c)

    doList: (collection, separator = ', ', prelude = '') ->
        return '' unless collection?.length > 0
        results = (i.toSql(@) for i in collection)
        return prelude + results.join(separator)

    columns: (columnList) ->
        return "*" if (columnList.length == 0)
        return @doList(columnList)

    tables: (tableList) -> @doList(tableList)

    joins: (joinList) -> @doList(joinList, ' ')

    from: (f) -> @aliasedExpression(f)
    join: (j) ->
        str = " INNER JOIN " + @column(j) + " ON " + j.predicate.toSql(@)

    select: (sql) ->
        q = "SELECT "

        for f in sql.tables
            if _.isString(f.expr)
                f._model = @db.tablesByAlias[f.expr]
                    
        ret = "SELECT #{@columns(sql.columns)} FROM #{@tables(sql.tables)}"

        ret += @joins(sql.joins)
        ret += @where(sql)
        ret += @groupBy(sql)
        ret += @orderBy(sql)
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
