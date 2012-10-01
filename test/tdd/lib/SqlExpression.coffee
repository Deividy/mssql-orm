# Link é para dizer basicamente se é and ou or, o nome link é pq ele é o que linka as clause
# op é = != > < >= <= LIKE IN

# Se algum dos valores de where for array ou object ele altera o valor de link caso seja array é 
# necessario ele conter um objeto, caso contrário kabum! Se for objeto é varrido e 
# verifica se a key é um operador, se for um operador ele usa o operador e da um replace nos 
# values, se for uma string ele concatena a query e procura o seu value se o 
# value for array ou object ele altera novamente a precedencia de link e varre esse objecto, caso
# seja array a coluna só é duplicada e jogada como OR, caso seja objeto a key é ncessário ser um 
# operador, caso não seja operador a query explode, exemplo:  age: { age: 50 } (é bem sick alguém
# fazer isso, mas se acontecer it explodes)

###
A ideia é enviar isso para alguma função do tipo buildExpression, ela fazer o replace e nos devolver 
a clause que queremos, nesse caso:
AND ( (login = 'deividy') OR (login = 'deeividy') OR (login = 'itsme!') )


        clause =  {
            link:         'AND' 
            op:         '='
            expression:    '$COLUMN$ $OP$ $VALUE$'            
            column:     'login' 
            value:         '' 
            values:     [ 'deividy', 'deeividy', 'itsme!' ] 
        }

###
_ = require('underscore')
fs = require('fs')

operators = JSON.parse(fs.readFileSync("../../../lib/operators.json", "utf-8"))

module.exports = 
    buildExpression: (exp, values) ->
        vals = ''

        exp = exp.replace("$COLUMN$", values.column)
        exp = exp.replace("%$VALUE$%", "'%#{values.value}%'")
        exp = exp.replace("$VALUE$", "'#{values.value}'")
        exp = exp.replace("$OP$", values.op)
        
        if (values.values.length is 2)
            exp = exp.replace("$VALUE[0]$", "'#{values.values[0]}'")
            exp = exp.replace("$VALUE[1]$", "'#{values.values[1]}'")

        
        if (values.values.length >= 1)
            c = 1
            for v in values.values
                if (c>1) then vals += ','
                vals += v 
                c++
            exp = exp.replace("$VALUES$",vals)

        return exp

    setOperator: (operators, c, v) ->
        if (operators[v].type is "expression")                
            c.expression = operators[v].expression
        else if (operators[v].type is "op")
            c.op = operators[v].op
        else if (operators[v].type is "link")
            c.link = operators[v].link
        return c

    jsonToClauses: (c, json) ->
        clause = []
        count = 1;
        closeClause = 0
        openClause = 0
        cLink = c.link

        for v of json
            if (count is 1) 
                openClause = 1
            else
                openClause = 0

            if (v.substring(0,1) is "$")
                c = @setOperator(operators, c, v)

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
                        console.error("INVALID QUERY: ", val)
                    else
                        if (val.substring(0,1) isnt "$")
                            cl.column = val
                        else
                            cl = @setOperator(operators, cl, val)
                    
                    if (_.isArray(json[v][val]))
                        cl.values = json[v][val] 
                    else
                        cl.value = json[v][val]
                    
                    if (count is 1) 
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

    jsonToClause: (json, c) ->
        clause = []
        if (!c)
            c =  {
                link:         operators['DEFAULT'].link
                op:         operators['DEFAULT'].op
                expression:    operators['DEFAULT'].expression            
                column:     '' 
                value:         '' 
                values:     [] 
            }        

        if (_.isArray(json))
            c.link = operators['ARRAY'].link
            for j in json
                cltemp = @jsonToClauses(c, j)
                if (_.isArray(cltemp))
                    for clt in cltemp
                        if (_.isObject(clt))
                            clause.push(clt)

        else if (_.isObject(json))
            c.link = operators['OBJECT'].link
            clause = @jsonToClauses(c, json)

                
        return clause


    clauseToStmt: (c) ->
        stmt = ""        
        if (_.isArray(c.values) and c.values.length >= 1 and c.expression is "$COLUMN$ $OP$ $VALUE$")
            stmt += " #{c.link} ("
            if (c.openClause) then stmt += " ( "
            c.link = operators['ARRAY'].link
            x=1
            for v in c.values
                exp = @buildExpression(c.expression, { column: c.column, value: v, op: c.op, values: c.values })
                if (x>1) then stmt+= "#{c.link}"
                stmt += " ( #{exp} ) "
                x++
            stmt += ")"
            if (c.closeClause) then stmt += " ) "
        else if (c.value or c.expression isnt "$COLUMN$ $OP$ $VALUE$")
            #c.link = operators['OBJECT'].link
            exp = @buildExpression(c.expression, { column: c.column, value: c.value, op: c.op, values: c.values })
            stmt += " #{c.link} "
            if (c.openClause) then stmt += " ( "
            stmt += " ( #{exp} ) "
            if (c.closeClause) then stmt += " ) "
            x++

        return stmt


    jsonToStmt: (json, stmt) ->
        if (!stmt) then where = ''
        c = @jsonToClause(json)
        if (_.isArray(c))
            for data in c
                if (_.isArray(data))
                    @jsonToStmt(data, where)
                else if (_.isObject(data))
                    where += @clauseToStmt(data)
        else if (_.isObject(c))
            where += @clauseToStmt(c)

        return where

    build: (data) ->        
        stmt = ""
        if (_.isArray(data))
            for json in data
                stmt += @jsonToStmt(json)
        else if (_.isObject(data))
            stmt += @jsonToStmt(data)
        else
            console.error("INVALID DATA", data)

        return stmt.substring(4)
