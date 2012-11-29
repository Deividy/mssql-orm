_ = require('underscore')
{ SqlPredicate, SqlToken, SqlSelect, SqlExpression, SqlRawName, SqlFullName } = sql = require('../sql')

SqlIdentifier = SqlToken.SqlIdentifier

rgxParseName = ///
    ( [^.]+ )   # anything that's not a .
    \.?         # optional . at the end
///g

rgxExpression = /[()\+\*\-/]/

class SqlFormatter
    constructor: (@db) ->
        @modelTables = []

    f: (v) ->
        return v.toSql(@) if v instanceof SqlToken
        return @literal(v)

    literal: (l) ->
        if (_.isString(l))
            return "'" + l.replace("'","''") + "'"

        return l.toString()

    parens: (contents) -> "(#{contents.toSql(@)})"

    isExpression: (e) -> _.isString(e) && rgxExpression.test(e)

    and: (terms) ->
        t = _.map(terms, @f, @)
        return "(#{t.join(" AND " )})"

    or: (terms) ->
        t = _.map(terms, @f, @)
        return "(#{t.join(" OR " )})"

    rawName: (n) -> @parseWhenRawName(n).toSql(@)

    fullName: (m) -> @joinNameParts(m.parts)

    joinNameParts: (names) -> _.map(names, (p) -> "[#{p}]").join(".")

    parseWhenRawName: (t) ->
        if t instanceof SqlFullName
            return t

        if t instanceof SqlRawName
            return @fullNameFromString(t.name)

        return t

    fullNameFromString: (s) ->
        parts = []
        while (match = rgxParseName.exec(s))
            parts.push(match[1])

        return new SqlFullName(parts)

    delimit: (s) ->
        return "[#{s}]"

    column: (c) ->
        token = @tokenizeAtom(c.atom)
        model = @findColumnModel(token)
        s = @_doToken(token, model)

        alias = @_doAlias(token, model, c.alias)
        if (alias?)
            s += " as #{@delimit(alias)}"

        return s

    _doToken: (token, model) ->
        if (model?)
            # MUST: we assume the column is a DB object at this point. We'll need to handle
            # virtual tables, columns, etc. one day
            if (p = token.prefix())
                return @joinNameParts([p, model.name])
            else
                return @delimit(model.name)
        else
            return @f(token)

    _doAlias: (token, model, alias) ->
        if alias?
            return alias

        if model?
            return model.alias

        if token instanceof SqlFullName
            return token.tip()

        return null

    _doAliasedExpression: (token, model, alias) ->
        e = @_doToken(token, model)
        a = @_doAlias(token, model, alias)

        return if a? then "#{e} as #{@delimit(a)}" else e


    relop: (left, op, right) ->
        leftToken = @tokenizeAtom(left)
        model = @findColumnModel(leftToken)
        l = @_doToken(leftToken, model)
        
        # MUST: replace with data driven approach
        op = op.toUpperCase()
        r = switch op
            when 'IN' then "(#{@f(right)})"
            when 'BETWEEN' then "#{@f(right[0])} AND #{@f(right[1])}"
            else
                rightToken = @parseWhenRawName(right)
                model = @findColumnModel(rightToken)
                r = @_doToken(rightToken, model)

        return "#{l} #{op} #{r}"

    doList: (collection, separator = ', ', prelude = '') ->
        return '' unless collection?.length > 0
        results = (i.toSql(@) for i in collection)
        return prelude + results.join(separator)

    columns: (columnList) ->
        return "*" if (columnList.length == 0)
        return @doList(columnList)

    tables: (tableList) -> @doList(tableList)

    joins: (joinList) -> @doList(joinList, ' ')

    from: (f) ->
        token = f._token
        model = f._model
        return @_doAliasedExpression(f._token, f._model, f.alias)

    join: (j) ->
        str = " INNER JOIN " + @column(j) + " ON " + j.predicate.toSql(@)

    tokenizeAtom: (atom) ->
        n = @parseWhenRawName(atom)
        if n instanceof SqlFullName
            return n

        if @isExpression(atom)
            return sql.expr(atom)

        if _.isString(atom)
            return @fullNameFromString(atom)

        return atom

    cacheExpressionToken: (e) -> e._token = @tokenizeAtom(e.atom)

    findColumnModel: (name) ->
        unless name instanceof SqlFullName
            return

        table = name.prefix()
        if table?
            return @db.tablesByAlias[table]?.columnsByAlias[name.tip()]

        for t in @modelTables
            column = t.columnsByAlias[name.tip()]
            if column?
                return column

    select: (sql) ->
        for t in sql.tables
            token = @cacheExpressionToken(t)
            if (token instanceof SqlFullName)
                t._model = @db.tablesByAlias[token.tip()]
                @modelTables.push(t._model) if t._model?

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
