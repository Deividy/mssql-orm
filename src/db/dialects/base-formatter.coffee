_ = require('underscore')
<<<<<<< HEAD
{ SqlPredicate, SqlIdentifierGuess } = require('./sql-tokens')
SqlSelect = require('./sql-select')

class SqlFormatter
    @f: (v) ->
        return "'" + v.replace("'","''") + "'" if (_.isString(v))
        return v.toString()
=======
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
>>>>>>> gustavo

    literal: (l) ->
        if (_.isString(l))
            return "'" + l.replace("'","''") + "'"

<<<<<<< HEAD
    # MUST: Refactor use sql-operator
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
=======
        return l.toString()

    parens: (contents) -> "(#{contents.toSql(@)})"

    relop: (left, op, right) ->
        # MUST: replace with data driven approach
        op = op.toUpperCase()
        r = switch op
            when 'IN' then "(#{@f(right)})"
            when 'BETWEEN' then "#{@f(right[0])} AND #{@f(right[1])}"
            else @f(right)
>>>>>>> gustavo

        return "#{@f(left)} #{op} #{r}"

<<<<<<< HEAD
    predicateObject: (obj) ->
        clauses = []
        if (obj instanceof SqlIdentifierGuess) then o = obj.given else o = obj
        for key, value of o
            key = "#{@delimit(obj.guessTable)}.#{@delimit(key)}" if (obj.guessTable?)

            if(_.isArray(value))
                values = _.reduce(value, (memo, val) -> "#{memo}, #{format(val)}")
                clauses.push("#{key} IN (#{values})")
            else if (_.isObject(value))
                clauses.push(@operator(key, value))
            else
                clauses.push("#{key} = #{format(value)}")

        return "(#{clauses.join(' AND ')})"

    predicateArray: (arr) ->
        clauses = []
        (clauses.push(@predicate(a)) for a in arr)
        return "(#{clauses.join(' OR ')})"

    predicate: (t) ->
        return t.toSql(@) if (t instanceof SqlPredicate)
        return "(#{t})" if (_.isString(t))
        return @predicateArray(t) if (_.isArray(t))
        return @predicateObject(t) if (_.isObject(t))
        throw new Error("Unsupported predicate " + t.toString())
=======
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
>>>>>>> gustavo

        s += " as #{@delimit(alias)}" if (alias?)
        return s

<<<<<<< HEAD
    and: (a, b) -> "(#{@predicate(a)} AND #{@predicate(b)})"

    or: (a, b) -> "(#{@predicate(a)} OR #{@predicate(b)})"
=======
    doList: (collection, separator = ', ', prelude = '') ->
        return '' unless collection?.length > 0
        results = (i.toSql(@) for i in collection)
        return prelude + results.join(separator)

    columns: (columnList) ->
        return "*" if (columnList.length == 0)
        return @doList(columnList)
>>>>>>> gustavo

    tables: (tableList) -> @doList(tableList)

    joins: (joinList) -> @doList(joinList, ' ')

<<<<<<< HEAD
    delimit: (s) -> "[#{s}]"
=======
    from: (f) -> @column(f)
    join: (j) ->
        str = " INNER JOIN " + @column(j) + " ON " + j.predicate.toSql(@)
>>>>>>> gustavo

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

<<<<<<< HEAD
    select: (c) ->
        ret = "SELECT #{@columns(c.columns)} FROM #{@tables(c.tables)} "
        ret += @getWhere(c)
        ret += @getHaving(c)
=======
    insert: (i) ->
        return "INSERT #{@f(i.targetTable)}"

    update: (u) ->
        ret = "UPDATE #{@f(u.targetTable)} SET "
        ret += @doList(u.exprs)
        ret += @where(u)
>>>>>>> gustavo
        return ret

    updateExpr: (e) -> "#{@f(e.column)} = #{@f(e.value)}"

<<<<<<< HEAD
    getWhere: (c) ->
        return "WHERE #{@predicate(c.whereClause)}" if (c.whereClause?)
        return ""
=======
    delete: (d) ->
        ret = "DELETE FROM #{@f(d.targetTable)}"
        ret += @where(d)
        return ret

p = SqlFormatter.prototype
p.format = p.f
>>>>>>> gustavo

module.exports = SqlFormatter
