fs = require('fs')
_ = require('underscore')

operators = JSON.parse(fs.readFileSync("#{__dirname}/operators.json", "utf-8"))

class SqlExpression
    _buildExpression = (exp, values) ->
        vals = ''

        exp = exp.replace("$COLUMN$", values.column)
        exp = exp.replace("%$VALUE$%", "'%#{values.value}%'")
        exp = exp.replace("$VALUE$", "'#{values.value}'")
        exp = exp.replace("$OP$", values.op)
        
        if (values.values.length >= 1)
            c = 1
            for v in values.values
                exp = exp.replace("$VALUE[#{c}]$", "'#{v}'")
                if (c>1) then vals += ','
                vals += v 
                c++
            exp = exp.replace("$VALUES$",vals)

        return exp

    _setOperator = (operators, c, v) ->
        if (operators[v].type == "expression")                
            c.expression = operators[v].expression
        else if (operators[v].type == "op")
            c.op = operators[v].op
        else if (operators[v].type == "link")
            c.link = operators[v].link

        return c
  
    _jsonToClause = (c, json) ->
        clause = []
        count = 1;
        closeClause = 0
        openClause = 0
        cLink = c.link

        for v of json
            if (count == 1) 
                openClause = 1
            else
                openClause = 0

            if (v.substring(0,1) == "$")
                c = _setOperator(operators, c, v)

            else
                c.column = v

            if (_.isArray(json[v]))    
                c.values = json[v]

            else if (_.isObject(json[v]))
                dgo = 1
                cl = c

                for val of json[v]
                    if (count>1)
                        cl.link = operators["OBJECT"].link

                    if (!_.isString(val))
                        throw new Error("Invalid query: \n #{val}")
                    else
                        if (val.substring(0,1) != "$")
                            cl.column = val
                        else
                            cl = _setOperator(operators, cl, val)
                    
                    if (_.isArray(json[v][val]))
                        cl.values = json[v][val] 
                    else
                        cl.value = json[v][val]
                    
                    if (count == 1) 
                        openClause = 1
                    else
                        openClause = 0

                    clause.push( 
                        link: cl.link
                        op: cl.op
                        expression: cl.expression
                        column: cl.column
                        value: cl.value
                        values: cl.values
                        openClause: openClause
                        closeClause: closeClause 
                    )
                    count++
            else
                c.value = json[v]

            if (!dgo)
                clause.push( 
                    link: cLink
                    op: c.op
                    expression: c.expression
                    column: c.column
                    value: c.value
                    values: c.values 
                    openClause: openClause
                    closeClause: closeClause
                )
                c.value = ''
                c.values = []
                cLink = operators["OBJECT"].link

            count++

            dgo = 0
        
        clause[(clause.length-1)].closeClause = 1
        return clause

    jsonsToClause: (json, c) ->
        clause = []
        if (!c)
            c =  {
                link: operators['DEFAULT'].link
                op: operators['DEFAULT'].op
                expression: operators['DEFAULT'].expression            
                column: '' 
                value: '' 
                values: [] 
            }        

        if (_.isArray(json))
            c.link = operators['ARRAY'].link
            for j in json
                cltemp = _jsonToClause(c, j)
                if (_.isArray(cltemp))
                    for clt in cltemp
                        if (_.isObject(clt))
                            clause.push(clt)

        else if (_.isObject(json))
            c.link = operators['OBJECT'].link
            clause = _jsonToClause(c, json)

                
        return clause

    clauseToStmt: (c) ->
        stmt = ""        
        if (_.isArray(c.values) && c.values.length >= 1 && 
                                    c.expression == "$COLUMN$ $OP$ $VALUE$")
            stmt += " #{c.link} ("
            if (c.openClause) then stmt += "("
            c.link = operators['ARRAY'].link
            x = 1
            for v in c.values
                exp = _buildExpression(c.expression, { 
                        column: c.column
                        value: v
                        op: c.op
                        values: c.values 
                })
                if (x>1) then stmt+= " #{c.link} "
                stmt += "(#{exp})"
                x++
            stmt += ")"
            if (c.closeClause) then stmt += ")"

        else if (c.value || c.expression != "$COLUMN$ $OP$ $VALUE$")
            exp = _buildExpression(c.expression, { 
                    column: c.column
                    value: c.value
                    op: c.op
                    values: c.values 
            })
            stmt += " #{c.link} "
            if (c.openClause) then stmt += "("
            stmt += "(#{exp})"
            if (c.closeClause) then stmt += ")"
            x++

        return stmt

    jsonToStmt: (json, stmt) ->
        if (!stmt) then where = ''
        c = @jsonsToClause(json)
        if (_.isArray(c))
            for data in c
                if (_.isArray(data))
                    @jsonToStmt(data, where)
                else if (_.isObject(data))
                    where += @clauseToStmt(data)
        else if (_.isObject(c))
            where += @clauseToStmt(c)

        return where

    buildClauses: (data) ->
        stmt = ""
        if (_.isArray(data))
            for json in data
                stmt += @jsonToStmt(json)
        else if (_.isObject(data))
            stmt += @jsonToStmt(data)
        else
            throw new Error("Invalid data on build! \n #{data}")

        return stmt.substring(4)


module.exports = SqlExpression
